# 
# Backup Job Processor.

require 'ftools'

class Job 
 
 attr_reader :errors
 
  def initialize(target, source, type, prerun, job_name, validate, rotate)
    @target = target
    @source = source
    @type = type.downcase
    @prerun = prerun
    @validate = validate
    @job_name = job_name
    @rotate = rotate
    @errors = 0
  end
 
  def start
    #execute the job
    log_entry("Backup Job " + @job_name + " Starting....")
    pre_run
    rotate
     for source in @source
      #need a regex to pull the source name out
      source_name = source.gsub(/\\/, '_') + "\\"
      system("net use r: /delete")
      if drive_map(source)
        case @type
        when 'diff', 'd', 'differential'
          log_entry("Job type = Differential")
          differential(source, source_name)
        when 'full', 'f'
          log_entry("Job type = Full")
          full(source, source_name)
        when 'incremental', 'i', 'inc'
          log_entry("Job type = Incremental")
          incremental(source, source_name)
        when 'copy', 'c'
          log_entry("Job type = Copy")
          copy(source, source_name)
        when 'bydate', 'b', 'date'
          log_entry("Job Type = Date Based")
          by_date(source, source_name)
        else
          log_error("Job Type Not Understood, exiting")
          return @errors
        end
      end
   end
   unless @errors == 0
     log_entry("All Targets backed up!")
   else
     log_error("Backup Finished with " + @errors.to_s + " errors")
   end
   return @errors
end
  
      
  def pre_run
    unless @prerun.nil?
      #do pre-run maintance here. Any prerun should be
      #handed off to the job as a batch file or other
      #commandline executeable
      log_entry("starting prerun")
      if system @prerun
        log_entry("prerun sucessful")
        return true
      else
        log_error("prerun failed, job halting")
        return false
      end
    else
      log_entry("No prerun defined")
      return true
    end
  end
 

  
  def full(source, source_name)
    #we do a full backup, reseting the archive bit on all files
    log_entry("Starting Backup")
    if xcopy(source.to_s + "\\* " + @target.to_s + "\\" + source_name + " /s /e /c /y /v /h")
      log_entry("Backup part " + source + " to " + @target + "\\" + source_name +" Sucessful")
    else
      log_entry("Backup had errors!")
      log_error("Could not copy from " + source.to_s + " to " + @target.to_s + "\\" + source_name)
    end
  end
 
  def copy(source)
    #we do a simple copy, not touching anything
    log_entry("Starting Backup")
    if xcopy(source.to_s + "\\* " + @target.to_s + "\\" + source_name + " /s /e /c /y /v")
      log_entry("Backup part " + source + " to " + @target + "\\" + source_name + " Sucessful")
    else
      log_entry("Backup had errors!")
      log_error("Could not copy from " + source.to_s + " to " + @target.to_s + "\\" + source_name)
    end
  end
  
  def by_date(source)
    #we back up files accessed since date, and reset the archive bit
    log_entry("Starting Backup")
    if xcopy(source.to_s + "\\* " + @target.to_s + "\\" + source_name + " /s /e /c /y /v /D:" + @fromdate)
      log_entry("Backup part " + source + " to " + @target + "\\" + source_name + " Sucessful")
    else
      log_entry("Backup had errors!")
      log_error("Could not copy from " + source.to_s + " to " + @target.to_s + "\\" + source_name)
    end
  end

  
  def incremental(source)
    #we backup files with the archive bit set, and reset the archive bit
    log_entry("Starting Backup")
    if xcopy(source.to_s + "\\* " + @target.to_s + "\\" + source_name + " /s /e /c /y /v /m")
      log_entry("Backup part " + source + " to " + @target + "\\" + source_name + " Sucessful")
    else
      log_entry("Backup had errors!")
      log_error("Could not copy from " + source.to_s + " to " + @target.to_s + "\\" + source_name)
    end
  end
  
  def differential(source)
    #we backup files with the archive bit set, and do not reset the bit
    log_entry("Starting Backup")
    if xcopy(source.to_s + "\\* " + @target.to_s + "\\" + source_name + " /s /e /c /y /v /a")
      log_entry("Backup part " + source + " to " + @target + "\\" + source_name + " Sucessful")
    else
      log_entry("Backup had errors!")
      log_error("Could not copy from " + source.to_s + " to " + @target.to_s + "\\" + source_name)
    end
  end

  def drive_map(source)
    if system("net use r: " + source)
        log_entry(source + " mapped to r drive")
        return true
     else
        log_error("Error on connection to source " + source + ", skipping")
        return false
    end
  end
  
  def log_entry(entry)
    @@log.log_entry(entry)
    puts entry
  end  
  
  def log_error(entry)
    log_entry(entry)
    @errors = @errors + 1
   end
  
  def rotate
   #rotate the jobs
   unless @rotate.nil?
     log_entry("Starting Rotation: Keeping " + @rotate.to_s + " old jobs")
     unless system("rmdir /S /Q " +@target.to_s + "." + @rotate.to_s)
     log_error("Cleaning of old rotation folder failed")
     else
       log_entry("Oldest rotation folder removed")
     end
     @rotate.times { |r|
        temp = @rotate - r
        log_entry "doing rotation number " + temp.to_s
        temp2 = @rotate - r - 1
        if system("move " + @target.to_s + "." + temp2.to_s + " " + @target.to_s + "." + temp.to_s)
          log_entry("rotation #" + r.to_s + " sucessful")
        else
          log_error("rotation #" + r.to_s + " Failed")
        end
     }
     system("move " + @target.to_s + " " + @target.to_s + ".0")
   end
  end
  
 def xcopy(args)
   system("xcopy " + args )
 end  
 
end

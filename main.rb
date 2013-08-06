# 
# SyncScript
# A simple file based backup program
# Used to stage daily backups to our NAS, as well as
# keep a few days of old backups laying around

#it's based on my earlyer Workstation Backeruper

#Stuff we need
require './mailer'
require './job'
require './config'
require './logger'
require './support'

puts 'Building Job'
@@log = Logger.new(@job_name)  
job = Job.new(@target, @sources, @type, @prerun, @job_name, @validate, @rotate)

puts 'Starting Job'
job.start

if job.errors - 1 == 0
  puts 'Job Sucessful'
  Mailer.new(
    "Backup job sucessful!", 
    "All resources backed up\n\n\n=======REPORT=FOLLOWS======\n\n\n" + @@log.dump.to_s, 
    @maillist).send
else
  puts 'Job needs attention! ' + job.errors.to_s + ' errors detected!'
  Mailer.new(
    "Backup job errors!", 
    "Backup job had " + job.errors.to_s + " errors, please check", 
    @maillist).send
end
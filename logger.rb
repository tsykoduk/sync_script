#logging functionality
require 'ftools'

class Logger

  def initialize(name)
    @filename = name.to_s + "_" + Time.now.to_f.to_s + ".txt"
    @file = File.new("log/" + @filename, 'a+') 
  end
  
  def log_entry(entry)
    logentry = Time.now.to_s + " \t" + entry.to_s + "\n"
    @file.printf(logentry)
    @file.flush
  end
  
  def dump
    IO.read("log/" + @filename)
  end

end

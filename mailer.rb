#Mailer - holds mail suppport routines
require 'open-uri'
require 'socket'
require 'net/smtp'

class Mailer

 def initialize(subject, body, to)
   @subject = subject
   @body = body
   @to = to
   @server = "ndcsmtp01"
 end
 
  def send
     if check_mail(@server)
        Net::SMTP.start(@server, 25) do |smtp|
          smtp.open_message_stream('BackupServer@spw.cbp.dhs.gov', @to) do |f|
            f.puts 'From: BackupServer@spw.cbp.dhs.gov'
            f.puts 'To: BackupServer@spw.cbp.dhs.gov'
            f.puts 'Subject: ' + @subject
            f.puts
            f.puts  @body
          end
         end
       return 0
     else
       return 1
    end
  end

  def check_mail(host)  
   port = 25
   ehlo = host
   Net::SMTP.start(host, port, ehlo) do |smtp|      
       return smtp.started?    
     end  
  end
end
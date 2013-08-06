#SyncScript Config
#
# Standard ruby lang here
# so you can do things like
# if date == Friday then ....

#List backup sources here as UNC paths,
#ie \\\\myserver\\myshare

@job_name = "Daily Backup"

@sources = [
  "\\\\someserver\\someshare",
  "\\\\someotherserver\\someothershare" #,

]

# Where do we want to store the backup?
#Do not use a trailing slash - bad things will happen



if Time.now.day.to_i % 2 != 0
  @target = "c:\\backups\\day"
else
  @target =  "e:\\backups\\day"
end

#Valid types: Date, Incremental, Diff, Full, Copy

@type = 'Full'

#Rotation Scheme
# Pass how many _old_ jobs you want to keep
# If you want to keep the most recient and 4 older backups
# pass 4. That will keep a total of 5 backups (your current and 4 old)
@rotate = 2
  
#if you want to pre-run a batch file or command line command, put it here

@prerun = nil

#Do you want crc32 validations done on all of the files after the run
#At this time, this is unimpletmented. the copy routine does a validation as it runs.

@validate = false

@maillist = [
  'youremailaddress@domain.com',
  'anotheremailaddress@domain.com'
]
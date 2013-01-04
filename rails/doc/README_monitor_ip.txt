# put the following line in the cronjob for an hourly check. any action is taken by the http service (like sending email when the IP of the server changed):

0 * * * * /usr/bin/wget -O /dev/null http://my.domain.org/system_config/check_ip 2> /dev/null       

# the log entries can be viewed via

grep check_ip log/audit.*

# the configuration (current IP and notification email address) can be done with the right permissions

http://my.domain.org/system_config/edit


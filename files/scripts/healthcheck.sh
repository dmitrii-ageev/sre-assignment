#!/bin/bash
# Start this script with 'nohup' command to keep it running when terminal detaches.

# Check the NGINX status.
curl --silent --fail http://localhost/index.html >/dev/null
if [ $? -eq 0 ]; then
    echo "NGINX server is up and running."
else
    echo "NGINX server is not responding properly!"
    exit -1
fi

# Print the most common word from the NGINX web page
curl -s localhost | sed 's/<[^>]*>//g' | tr -c '[:alpha:]' '[\n*]' | tr '[:upper:]' '[:lower:]' | sed '/^\s*$/d' | grep -v [0-9] | sort | uniq -c | sort -rn | head -1 | awk '{ print $2 }'

# Poll NGINX resources every 10 seconds, and send the output to the /var/www/resourse.log file
# or quit if another instance of the script is already running.
if pidof -x "$(basename $0)" -o $$ > /dev/null; then
    echo "The script is already running!"
    exit -1
fi
until false; do
    (date;docker stats nginx --no-stream; echo) >> /var/log/resource.log
    # Note: the container status check takes about 2 seconds, which is weird by the way.
    sleep 8
done

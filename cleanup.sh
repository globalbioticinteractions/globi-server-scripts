rm /home/jhpoelen/export-eol-globi-data.log
rm /home/jhpoelen/index-taxa.log
# removes files older than 30 days from globi repo
find ~/.m2/repository/org/eol/* -mtime +30 | xargs rm

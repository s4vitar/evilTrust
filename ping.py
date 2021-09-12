import ftplib
import time
import sys
from datetime import datetime
import json

while True:
        current_timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
        print('uploading at:'+current_timestamp)
        data = {}
        data['alive_at'] = current_timestamp

        with open('ping.json', 'w') as outfile:
                json.dump(data, outfile)

        session = ftplib.FTP('server','user','password')
        file = open('ping.json','rb')                  # file to send
        session.storbinary('STOR ping.json', file)     # send the file
        file.close()                                    # close file and FTP
        session.quit()
        print('uploaded')
        time.sleep(30)
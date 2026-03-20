Deployment Instructions:

1. Download your class roster using export csv from the gradebook. Create a new folder called student_csv and put the csv file into there.

2. run the python script: csv_to_json.py to change your CSV into a json called students.json

3. Ensure you have ssh access to a new install of ubuntu (I used 24.04) on a server (I used digital ocean)

4. Navigate to this folder in a terminal/powershell

5. Run the following commands:

scp .\initial_setup.sh root@144.126.216.174:~
scp .\class_setup.sh root@144.126.216.174:~
scp .\students.json root@144.126.216.174:~

Replace YOUR_IP with the ip address of your server computer.

6. SSH into your machine as root user from terminal/powershell

7. verify the files exist:
    ls -l ~
You should see the three files.

8. Make the files executable:
chmod +x initial_setup.sh class_setup.sh

9. Run the initial setup:
sudo ./initial_setup.sh

You may see a Configuring openssh-server prompt. 
Choose *keep the local version currently installed*

10. Run the class setup:
sudo ./class_setup.sh

This will create users on the server machine for each student from the student list using their oregon state username as their username on your server.

11. student_credentials.csv should be created

You should need this file, but you can scp it from your server to your computer if you need the passwords.
The student directories will also have their database credentials in a db_info.txt
By default all student passwords will be changeme and they will be forced to change their passwords when they log in

Students can log in by using ssh username@ipaddress (they don't need SSH keys, they will use password authentication)

From there, they'll be able to ssh in, change their password, and they'll also be able to sftp in (using Filezilla or similar) and transfer files to their public_html folder.

Their website is viewable at YOUR_IP/~username
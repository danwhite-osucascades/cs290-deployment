# Class Server Deployment Instructions

This guide walks you through setting up student accounts on a new Ubuntu server and preparing each student’s web space.

This has been tested with *DigitalOcean Droplets* and *AWS Lightsail Instances*.

NOTE: Lightsail uses a *ubuntu* user instead of a *root* user, so if you are using Lightsail, replace *root* with *ubuntu* in any of the instructions.

---

## Prerequisites

- A CSV export of your class roster from the gradebook.  
- SSH access to a clean Ubuntu installation (tested with **Ubuntu 24.04**) on a server.  
- Python installed locally to convert CSV → JSON.  
- Terminal or PowerShell access.

---

## Step 1 — Prepare Student Data

1. Create a folder in your project called `student_csv`.  
2. Place your exported CSV file into the `student_csv` folder.  
3. Convert the CSV into JSON by running the Python script:

```bash
python csv_to_json.py
```

This will generate a file named `students.json`.

---

## Step 2 — Transfer Files to the Server

From your local machine, navigate to the folder containing the scripts and JSON file, then run the following commands:

```bash
scp ./initial_setup.sh root@YOUR_IP:~
scp ./class_setup.sh root@YOUR_IP:~
scp ./students.json root@YOUR_IP:~
```

> Replace `YOUR_IP` with the IP address of your server.

---

## Step 3 — SSH Into the Server

Connect to your server as the root user:

```bash
ssh root@YOUR_IP
```

Verify the files were successfully uploaded:

```bash
ls -l ~
```

You should see:

- `initial_setup.sh`
- `class_setup.sh`
- `students.json`

---

## Step 4 — Prepare Scripts for Execution

Make both shell scripts executable:

```bash
chmod +x initial_setup.sh class_setup.sh
```

---

## Step 5 — Run Initial Setup

Run the initial setup script:

```bash
sudo ./initial_setup.sh
```

> You may see a prompt for **Configuring openssh-server**.  
> Choose: **Keep the local version currently installed**.

---

## Step 6 — Create Student Accounts

Run the class setup script:

```bash
sudo ./class_setup.sh
```

This will:

- Create user accounts for each student using their Oregon State username.  
- Generate a `student_credentials.csv` file containing their login info.  
- Place database credentials in each student’s `db_info.txt`.  
- Set default passwords to `changeme` and force students to change them on first login.

---

## Step 7 — Accessing Student Accounts

Students can:

- Log in via SSH:

```bash
ssh username@YOUR_IP
```

- Change their password upon first login.  
- Use SFTP (e.g., FileZilla) to transfer files to their `public_html` folder.

Each student’s website will be available at:

```bash
http://YOUR_IP/~username
```

> If needed, you can `scp` the `student_credentials.csv` back to your local machine for reference.

---

## Notes

- SSH keys are **not required**; password authentication is sufficient.  
- Ensure that your firewall allows HTTP (port 80) if students need to access their websites.

---

## Reset Student Password

To reset a student's password from sudo user:

`passwd whiteda3`

You will be prompted to set the password

`chage -d 0 username`

This will force the user to change their password when they log in.
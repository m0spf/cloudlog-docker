# cloudlog-docker

- This is a docker-compose config plus a set of scripts that grabs the latest Cloudlog and hosts it using nginx with php-fpm with SSL (letsencrypt if public, or self signed if local). It also runs a container for processing the cron jobs that cloudlog requires
- It does the basic set-up and configuration of cloudlog
    - Creates database
    - Creates cloudlog user account
    - Sets up cron jobs
    - Automatically backs up database and cloudlog files every night
    - Runs under TLS using letsencrypt if publically accessible, or with self signed certs if not
    
- It has a set of scripts to install, start, stop and update

- Documentation still a work in progress.

- To use, clone this repo and:
  - cp .env.sample .env
  - edit .env with your details
  - ./install.sh
  
 - Once installed you will need to create a station profile and populate the country files (on the admin menu) before you can log QSOs
 
 - If you are familiar with cloudlog not on docker then you will find the cloudlog files at ./data/cloudlog where you can edit/import as you please.
 
 - To import a SQL database you might already have, run install.sh and then exit when it asks to start, place your sql backup file in ./data/initdb.d and remove the install.sql file in there. Now run ./start.sh and it should import the database. You can do the same for the cloudlog files.
  
Issues, PRs etc welcome

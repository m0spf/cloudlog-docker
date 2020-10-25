# cloudlog-docker

- This is a set of scripts that grabs the latest Cloudlog and hosts it using nginx with php-fpm with SSL (letsencrypt if public, or self signed if local).
- It does the basic set-up and configuration of cloudlog
    - Creates database
    - Creates cloudlog user account
    - Sets up cron jobs
    - Automatically backs up database and cloudlog files every night
    
- It has a set of scripts to install, start, stop and update

Documentation still a work in progress.

To use, clone this repo and:
  - cp .env.sample .env
  - edit .env with your details
  - ./install.sh
  
 Once installed you will need to create a station profile and populate the country files (on the admin menu) before you can log QSOs
  

# MT Grid Backup
**A simple, automated site backup utility for Media Temple Grid hosting**

Want to keep your sites and data backed up, but don't want to shell out sizeable amounts of cash every month for expensive backup services?  MT Grid Backup is an affordable option for developers working with Media Temple's Grid Hosting service.

## Installation

Before you begin, you must have an Amazon Web Services account set up.  You should make sure you have an S3 bucket created and access to the necessary security keys.  Once you've done that:

1. Clone this repository to a directory called "ez-s3-backup" on your host server.  It is **highly recommended** that you place the folder outside of any public directories such as "public_html". On Media Temple, I keep my repository in the `~/data` directory. 

2. Get [Composer](https://getcomposer.org/download/) if you don't already have it on your server.  If you don't have command line access, you can download composer.phar to your local machine and upload it to `ez-s3-backup/composer.phar` on your server via FTP.

3. From inside the ez-s3-backup directory, run `php composer.phar install` which will install the program dependencies, namely AWS-SDK-PHP.  You should now have a /vendor folder inside the current directory.

4. Rename backup.conf.sample to backup.conf

5. Edit backup.conf, filling in the necessary access credentials

6. Set up your cron jobs.  To do this using Media Temple Grid, simply log in to your control panel, and navigate to 'Cron Jobs' located under 'File Management'.  See cron.sample for the various jobs you'll want to create (4 in all). Alternatively, if you have command-line access to the crontab you can use the example jobs available in cron.sample as a starting point.





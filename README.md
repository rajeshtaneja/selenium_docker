# Selenium image to run moodle acceptance tests.
![logo](https://moodle.org/theme/image.php/moodleorgcleaned_moodleorg/theme_moodleorgcleaned/1447866970/moodle-logo)

## Initial setup
Initial setup needed on host machine.

### Step 1: Install [docker]
* [Install docker binary]
> Create a [docker group] to avoid using sudo while executing scripts.
> NOTE: You need to logout and login to  make group affective.

## Step 2: Run selenium instance
* docker run -ti -v /PATH_OF_MOODLE_ON_HOST:/moodle rajeshtaneja/selenium:2.53.0 {PROFILENAME}
> NOTE: Map moodle folder on host to /moodle in selenium docker instance so @_file_upload can work.

## Profile names supported
* default
* firefox
* chrome
* phantomjs
* phantomjs-selenium

## Versions installed
* firefox: 46.0.1
* chrome: 51.0.2704.106
* phantomjs: 2.1.1
* Selenium: 2.53.0

[official]: <https://hub.docker.com/u/moodlehq/>
[docker]: <https://www.docker.com/>
[docker group]: <https://docs.docker.com/v1.8/installation/ubuntulinux/#create-a-docker-group>
[Install docker binary]: <http://docs.docker.com/engine/installation/>

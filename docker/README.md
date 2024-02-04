## Installation steps for a dockerized Luminance

Run the script for the first time, it will create a `.env` file from the template:
```
chmod +x run.sh
./run.sh
```

Edit the `.env` file, using `nano` here:
```
nano .env
```

Install Docker and Compose:
```
./run.sh install_docker
```

Build the images:
```
./run.sh build
```

Database installation, it will be located in the `Luminance/database` folder, and configurations:
```
./run.sh install_luminance
```

Edit the `settings.ini` file, using `nano` here:
```
nano ../application/settings.ini
```

Start the containers, they will run in the background, you can check them with `./runs.sh logs`:
```
./run.sh start
```

## Usage and other commands of `run.sh`
```
Usage: ./run.sh <command> <argument>

Commands: 
 help              - this help screen
 install_docker    - install Docker and Docker Compose
 install_luminance - install and configure Luminance
 build             - build the docker images
 start             - start the docker containers
 stop              - stop the docker containers
 restart           - restart the docker containers
 kill              - force stop the docker containers
 status            - list the currently running containers
 enter <container> - enter a container with a bash session
 logs              - live logs of the running containers
 reload_nginx      - reload nginx in its container, useful when testing nginx configs
 ```

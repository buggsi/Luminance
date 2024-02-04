#!/usr/bin/env bash
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain

if [[ ! -f .env ]]; then
    echo "*** Missing .env, copying from sample file"
    echo "*** Edit its parameters and re-run this script"
    cp -np .env.sample .env
    # Secure the .env file, it contains sensitive data.
    chmod 600 .env
    exit
fi

help() {
    echo "Usage: $0 <command> <argument>"
    echo
    echo "Commands: "
    echo " install_docker    - install Docker and Docker Compose"
    echo " install_luminance - install and configure Luminance"
    echo " build             - build the docker images"
    echo " start             - start the docker containers"
    echo " stop              - stop the docker containers"
    echo " restart           - restart the docker containers"
    echo " kill              - force stop the docker containers"
    echo " status            - list the currently running containers"
    echo " enter <container> - enter a container with a bash session"
    echo " logs              - live logs of the running containers"
    echo " reload_nginx      - reload nginx in its container, useful when testing nginx configs"
    echo
    exit
}

install_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Missing Docker. Installing it now, requires root or sudo privileges."
        sleep 2

        curl -fsSL https://get.docker.com | sh

        # Permission for current user to run docker as non-root
        if [ $EUID -ne 0 ]; then
            sudo groupadd docker
            sudo usermod -aG docker $USER
            echo "Log out and log back in so that your group membership is re-evaluated"
            echo "Then re-run this script to verify the installation"
            exit
        fi
    else
        docker --version | sed 's/$/ ✓ OK/'
    fi

    if docker compose version 2>&1 >/dev/null | grep -q 'is not a docker command'; then
        echo "Missing Docker Compose. Installing it now for the current user."
        # New docker Compose V2 plugin. Already included in the docker setup script above.
        # https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
        sleep 2
        exit
        DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
        mkdir -p $DOCKER_CONFIG/cli-plugins
        version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*\d')
        curl -SL https://github.com/docker/compose/releases/download/$version/docker-compose-$(uname -s)-$(uname -m) -o $DOCKER_CONFIG/cli-plugins/docker-compose
        chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
    else
        docker compose version | sed 's/$/ ✓ OK/'
    fi
}

install_luminance() {
    # Copy settings from template
    cp -np ../application/settings.ini.template ../application/settings.ini

    if [ $EUID -ne 0 ]; then
        user=www-data
    else
        user=root
    fi
    # Run the setup install first, so the database is created before doing the configuration
    start
    docker compose exec -u $user service_php php application/entry.php setup install
    docker compose exec -u $user service_php php application/entry.php setup configure
    stop
}

build() {
    # Variables passed as ARG via yaml to Dockerfile
    user=$(id -nu)
    group=$(id -ng)
    uid=$(id -u)
    gid=$(id -g)

    echo Checking/adding variables to .env
    grep 'user=' .env || echo user=$user >>.env
    grep 'group=' .env || echo group=$group >>.env
    grep 'uid=' .env || echo uid=$uid >>.env
    grep 'gid=' .env || echo gid=$gid >>.env
    sleep 2

    # Build the docker containers while pulling the latest images
    docker compose build --pull --no-cache

    # Install the PHP dependencies with Composer
    if [ $EUID -ne 0 ]; then
        user=www-data
    else
        user=root
    fi
    docker compose run --rm -u $user service_php composer install
}

start() {
    echo $1
    if [[ ! -z $1 ]]; then
        docker compose up -d $1
    else
        docker compose up -d
    fi
    # Wait for all services to be started
    docker compose run --rm wait -c service_mysql:3306,service_nginx:80,service_php:9000
    clean_docker
}

stop() {
    docker compose down
    clean_docker
}

kill() {
    docker compose kill
    docker compose rm -f
    clean_docker
}

status() {
    docker compose ps --services --filter "status=running"
}

enter() {
    docker exec -it $1 bash
}

logs() {
    docker compose logs --tail=50 --follow
}

reload_nginx() {
    docker compose kill -s SIGHUP service_nginx
}

clean_docker() {
    echo Cleaning up docker remnants
    echo Pruning unused volumes
    docker volume prune -f
    echo Pruning unused networks
    docker network prune -f
    docker ps -a -q -f status=exited | xargs docker rm &>/dev/null
    docker images | grep '<none>' | awk '{print $3}' | xargs docker rmi -f &>/dev/null
}

if [ "$#" -lt 1 ]; then
    help
fi

case $1 in
install_docker)
    install_docker
    ;;
install_luminance)
    install_luminance
    ;;
build)
    build
    ;;
start)
    start $2
    ;;
stop)
    stop
    ;;
restart)
    stop
    start
    ;;
kill)
    kill
    ;;
status)
    status
    ;;
enter)
    enter $2
    ;;
logs)
    logs
    ;;
reload_nginx)
    reload_nginx
    ;;
*)
    echo "Invalid command"
    help
    ;;
esac

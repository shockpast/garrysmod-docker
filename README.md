[![Garry's mod containers](https://i.imgur.com/QEGv6GM.png "Garry's mod containers")][docker-hub-repo]

> [!NOTE]
> It's fork of ceifa's docker images, but with some additions?...

# Garry's Mod server
Run a Garry's Mod server easily inside a docker container

## Supported tags
* `latest` - the most recent production-ready image, based on `debian`
* `debian` - a gmod server based on debian
* `debian-x64` - (NOT STABLE YET) a gmod server based on debian but running on beta version of srcds for x64 bit CPUs
* `debian-root` - same as `debian` but executed as root user
* `debian-x64-root` - same as `debian-x64` but executed as root user
* `debian-post` - same as `debian` but the server is installed with the container starting
* `ubuntu` - a gmod server based on ubuntu, versioned as `18.04`
* `ubuntu-latest` - a gmod server based on latest ubuntu, versioned as `24.04`

## Features

* Run a server under a linux non-root user
* Run a server under an anonymous steam user
* Run server commands normally
* Check and update server automatically
* Production and development build

## Documentation

### Ports
The container uses the following ports:
* `:27015 TCP/UDP` as the game transmission, pings and RCON port
* `:27005 UDP` as the client port

You can read more about these ports on the [official srcds documentation][srcds-connectivity].

### Environment variables

**`PRODUCTION`**

Set if the server should be opened in production mode. This will make hot reload modifications to lua files not working. Possible values are `0`(default) or `1`.

**`HOSTNAME`**

Set the server name on startup.

**`MAXPLAYERS`**

Set the maximum players allowed to join the server. Default is `16`.

**`GAMEMODE`**

Set the server gamemode on startup. Default is `sandbox`.

**`MAP`**

Set the map gamemode on startup. Default is `gm_construct`.

**`PORT`**

Set the server port on container. Default is `27015`.

**`GSLT`**

Set the server GSLT credential to be used.

**`ARGS`**

Set any other custom args you want to pass to srcds runner.

### Directory structure
It's not the full directory tree, I just put the ones I thought most important

```cs
📦 /home/gmod // The server root
|__📁steamcmd // Steam cmd, used to update the server when needed
|__📁server
|  |__📁garrysmod
|  |  |__📁addons // Put your addons here
|  |  |__📁gamemodes // Put your gamemodes here
|  |  |__📁data
|  |  |__📁cfg
|  |  |  |__⚙️server.cfg
|  |  |__📁lua
|  |  |__📁cfg
|  |  |__💾sv.db
|  |__📃srcds_run
|__📃start.sh // Script to start the server
|__📃update.txt // Steam cmd script to run before start the server
```

## Examples

This will start a simple server in a container named `gmod-server`:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    --name gmod-server \
    -it \
    shockpast/garrysmod:latest
```

This will start a server with host workshop collection pointing to [382793424][workshop-example] named `gmod-server`:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    -e ARGS="+host_workshop_collection 382793424" \
    -it \
    shockpast/garrysmod:latest
```

This will start a server named `my server` in production mode pointing to a local addons with a custom gamemode:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    -v $PWD/addons:/home/gmod/server/garrysmod/addons \
    -v $PWD/gamemodes:/home/gmod/server/garrysmod/gamemodes \
    -e HOSTNAME="my server" \
    -e PRODUCTION=1 \
    -e GAMEMODE=darkrp \
    -it \
    shockpast/garrysmod:latest
```

You can create a new docker image using this image as base too:

```dockerfile
FROM shockpast/garrysmod:latest

COPY ./addons /home/gmod/server/garrysmod/addons

ENV NAME="My Garry's Mod Server"
ENV ARGS="+host_workshop_collection 1234567890"
ENV MAP="gm_construct"
ENV GAMEMODE="sandbox"
ENV MAXPLAYERS="32"
```

You can also use it inside docker compose:

```yml
services:
    gmod:
        image: shockpast/garrysmod:latest
        container_name: gmod
        restart: unless-stopped
        ports:
            - 27015:27015/udp
            - 27005:27005/udp
            - 27015:27015
        volumes:
            - ./addons:/home/gmod/server/garrysmod/addons
            - ./data:/home/gmod/server/garrysmod/data

            - ./sv.db:/home/gmod/server/garrysmod/sv.db
            - ./cfg/server.cfg:/home/gmod/server/garrysmod/cfg/server.cfg

            - gmod_steam_cache:/home/gmod/server/steam_cache
            - gmod_server_cache:/home/gmod/server/garrysmod/cache
        env_file: .env   # all configurations are stored inside .env file
        stdin_open: true # stdin_open and tty are required
        tty: true

volumes:
  gmod_steam_cache: # for workshop
  gmod_server_cache: # for workshop
```

More examples can be found at [my real use case github repository][lory-repo].

## Health Check

This image contains a health check to continually ensure the server is online. That can be observed from the STATUS column of docker ps

```sh
CONTAINER ID        IMAGE                    COMMAND                 CREATED             STATUS                    PORTS                                                                                     NAMES
e9c073a4b262        ceifa/garrysmod:latest        "/home/gmod/start.sh"   21 minutes ago      Up 21 minutes (healthy)   0.0.0.0:27005->27005/tcp, 27005/udp, 0.0.0.0:27015->27015/tcp, 0.0.0.0:27015->27015/udp   distracted_cerf
```

You can also query the container's health in a script friendly way:

```sh
> docker container inspect -f "{{.State.Health.Status}}" e9c073a4b262
healthy
```

## License

This image is under the [MIT license](license).

## TODO:

* Add multi-stages to build

[docker-hub-repo]: https://hub.docker.com/r/shockpast/garrysmod "Docker hub repository"

[srcds-connectivity]: https://developer.valvesoftware.com/wiki/Source_Dedicated_Server#Connectivity "Valve srcds connectivity documentation"

[license]: https://github.com/ceifa/garrysmod-docker/blob/master/LICENSE "License of use"

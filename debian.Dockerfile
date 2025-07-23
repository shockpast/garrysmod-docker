# BASE IMAGE
FROM debian:bookworm-slim

LABEL maintainer="shockpast"
LABEL description="A structured Garry's Mod dedicated server under a debian linux image"

ENV DEBIAN_FRONTEND=noninteractive

# INSTALL NECESSARY PACKAGES
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    wget ca-certificates tar gcc g++ \
    libcurl4-gnutls-dev:i386 libcurl4:i386 lib32z1 libstdc++6 lib32stdc++6 \
    libtinfo5 libncurses5:i386 libsdl1.2debian libfontconfig1 \
    gdb net-tools libc6-i386 libx11-6:i386 libxext6:i386 libxrender1:i386 \
    libfreetype6:i386 zlib1g:i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# SET STEAM USER
RUN useradd -d /home/gmod -m steam
USER steam
RUN mkdir -p /home/gmod/server /home/gmod/steamcmd

# INSTALL STEAMCMD
RUN wget -P /home/gmod/steamcmd/ https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf /home/gmod/steamcmd/steamcmd_linux.tar.gz -C /home/gmod/steamcmd && \
    rm -rf /home/gmod/steamcmd/steamcmd_linux.tar.gz

# SETUP STEAMCMD TO DOWNLOAD GMOD SERVER
COPY assets/update.txt /home/gmod/update.txt
RUN /home/gmod/steamcmd/steamcmd.sh +runscript /home/gmod/update.txt +quit

# SETUP BINARIES FOR x32 and x64 bits
RUN mkdir -p /home/gmod/.steam/sdk32 && \
    cp -v /home/gmod/steamcmd/linux32/steamclient.so /home/gmod/.steam/sdk32/steamclient.so && \
    mkdir -p /home/gmod/.steam/sdk64 && \
    cp -v /home/gmod/steamcmd/linux64/steamclient.so /home/gmod/.steam/sdk64/steamclient.so

# CREATE DATABASE FILE
RUN touch /home/gmod/server/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p /home/gmod/server/steam_cache/content && \
    mkdir -p /home/gmod/server/garrysmod/cache/srcds

# PORT FORWARDING
EXPOSE 27015
EXPOSE 27015/udp
EXPOSE 27005/udp

# SET ENVIRONMENT VARIABLES
ENV MAXPLAYERS="16"
ENV GAMEMODE="sandbox"
ENV MAP="gm_construct"
ENV PORT="27015"

# ADD START SCRIPT
COPY --chown=steam:steam assets/start.sh /home/gmod/start.sh
RUN chmod +x /home/gmod/start.sh

# CREATE HEALTH CHECK
COPY --chown=steam:steam assets/health.sh /home/gmod/health.sh
RUN chmod +x /home/gmod/health.sh
HEALTHCHECK --start-period=10s CMD /home/gmod/health.sh

# START THE SERVER
CMD ["/home/gmod/start.sh"]

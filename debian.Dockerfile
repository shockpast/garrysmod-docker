FROM debian:bookworm-slim

LABEL maintainer="shockpast"
LABEL description="A structured Garry's Mod dedicated server under a Debian image"

RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends libc6:i386 libstdc++6:i386 libncurses6:i386 curl screen wget ca-certificates tar bzip2 gzip unzip gdb passwd \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m -d /home/gmod steam \
 && mkdir -p /home/gmod/steamcmd /home/gmod/.steam/sdk32 /home/gmod/.steam/sdk64 \
 && chown -R steam:steam /home/gmod

USER steam

RUN wget -P /home/gmod/steamcmd/ --no-check-certificate https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -xvzf /home/gmod/steamcmd/steamcmd_linux.tar.gz -C /home/gmod/steamcmd \
 && rm -f /home/gmod/steamcmd/steamcmd_linux.tar.gz

COPY --chown=steam:steam assets/start.sh /home/gmod/start.sh
COPY --chown=steam:steam assets/health.sh /home/gmod/health.sh
COPY --chown=steam:steam assets/update.txt /home/gmod/update.txt
RUN chmod +x /home/gmod/start.sh /home/gmod/health.sh

HEALTHCHECK --start-period=10s CMD /home/gmod/health.sh

EXPOSE 27015 27015/udp 27005/udp

CMD ["/home/gmod/start.sh"]

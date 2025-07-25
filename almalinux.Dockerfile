FROM almalinux:9

LABEL maintainer="shockpast"
LABEL description="A structured Garry's Mod dedicated server under a AlmaLinux image"

RUN dnf -y install epel-release \
 && dnf -y install --allowerasing glibc.i686 libstdc++.i686 ncurses-compat-libs curl screen wget tar bzip2 gzip unzip gdb shadow-utils \
 && dnf clean all \
 && rm -rf /var/cache/dnf /var/tmp/*

RUN useradd -m -d /home/gmod steam \
 && mkdir -p /home/gmod/steamcmd /home/gmod/.steam/sdk32 /home/gmod/.steam/sdk64 \
 && chown -R steam:steam /home/gmod

USER steam

RUN wget -P /home/gmod/steamcmd/ https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
 && tar -xvzf /home/gmod/steamcmd/steamcmd_linux.tar.gz -C /home/gmod/steamcmd \
 && rm -f /home/gmod/steamcmd/steamcmd_linux.tar.gz

COPY --chown=steam:steam assets/start.sh /home/gmod/start.sh
COPY --chown=steam:steam assets/health.sh /home/gmod/health.sh
COPY --chown=steam:steam assets/update.txt /home/gmod/update.txt
RUN chmod +x /home/gmod/start.sh /home/gmod/health.sh

HEALTHCHECK --start-period=10s CMD /home/gmod/health.sh

EXPOSE 27015 27015/udp 27005/udp

CMD ["/home/gmod/start.sh"]

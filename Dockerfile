# To use this Docker container, make sure you set up the mounts properly.
#
# The Minecraft server files are expected at
#     /home/minecraft/server
#
# The Minecraft-Overviewer render will be output at
#     /home/minecraft/render

FROM debian:jessie

ENV MINECRAFT_VERSION 1.10.2

RUN echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y wget && \
    wget -O - http://overviewer.org/debian/overviewer.gpg.asc | apt-key add - && \
    wget https://s3.amazonaws.com/Minecraft.Download/versions/${MINECRAFT_VERSION}/${MINECRAFT_VERSION}.jar -P /home/minecraft/.minecraft/versions/${MINECRAFT_VERSION}/ && \
    apt-get update && \
    apt-get install -y minecraft-overviewer && \
    apt-get remove -y wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    useradd -m minecraft && \
    mkdir -p /home/minecraft/render /home/minecraft/server

COPY config/config.py /home/minecraft/config.py

RUN chown minecraft:minecraft -R /home/minecraft/

WORKDIR /home/minecraft/

USER minecraft

CMD ["overviewer.py", "--config", "/home/minecraft/config.py"]

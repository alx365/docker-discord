# References:
#   https://hub.docker.com/r/solarce/zoom-us
#   https://github.com/sameersbn/docker-skype
FROM archlinux
MAINTAINER alx365


ENV DEBIAN_FRONTEND noninteractive

# Refresh package lists
RUN yes | pacman -Syu
#RUN apt-get -qy dist-upgrade

# Dependencies for the client .deb
RUN yes | pacman -S discord
#ARG ZOOM_URL=https://zoom.us/client/latest/zoom_amd64.deb

# Grab the client .deb
# Install the client .deb
# Cleanup
#RUN curl -sSL $ZOOM_URL -o /tmp/zoom_setup.deb
#RUN dpkg -i /tmp/zoom_setup.deb
#RUN apt-get -f install
#RUN rm /tmp/zoom_setup.deb \
#  && rm -rf /var/lib/apt/lists/*

COPY scripts/ /var/cache/discord/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

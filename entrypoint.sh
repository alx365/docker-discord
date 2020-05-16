#!/bin/bash
set -e

USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-1000}

discord_USER=discord

install_discord() {
  echo "Installing discord-wrapper..."
  install -m 0755 /var/cache/discord/discord-wrapper /target/
  echo "Installing discord..."
  ln -sf discord-wrapper /target/discord
}

uninstall_discord() {
  echo "Uninstalling discord-wrapper..."
  rm -rf /target/discord-wrapper
  echo "Uninstalling discord..."
  rm -rf /target/discord
}

create_user() {
  # create group with USER_GID
  if ! getent group ${discord_USER} >/dev/null; then
    groupadd -f -g ${USER_GID} ${discord_USER} >/dev/null 2>&1
  fi

  # create user with USER_UID
  if ! getent passwd ${discord_USER} >/dev/null; then
    adduser --disabled-login --uid ${USER_UID} --gid ${USER_GID} \
      --gecos 'discordUs' ${discord_USER} >/dev/null 2>&1
  fi
  chown ${discord_USER}:${discord_USER} -R /home/${discord_USER}
  adduser ${discord_USER} sudo
}

grant_access_to_video_devices() {
  for device in /dev/video*
  do
    if [[ -c $device ]]; then
      VIDEO_GID=$(stat -c %g $device)
      VIDEO_GROUP=$(stat -c %G $device)
      if [[ ${VIDEO_GROUP} == "UNKNOWN" ]]; then
        VIDEO_GROUP=discordvideo
        groupadd -g ${VIDEO_GID} ${VIDEO_GROUP}
      fi
      usermod -a -G ${VIDEO_GROUP} ${discord_USER}
      break
    fi
  done
}

launch_discord_us() {
  cd /home/${discord_USER}
  exec -HEu ${discord_USER} PULSE_SERVER=/run/pulse/native QT_GRAPHICSSYSTEM="native" $@
}

case "$1" in
  install)
    install_discord
    ;;
  uninstall)
    uninstall_discord
    ;;
  discord)
    create_user
    grant_access_to_video_devices
    echo "$1"
    launch_discord $@
    ;;
  *)
    exec $@
    ;;
esac

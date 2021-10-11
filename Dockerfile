FROM ubuntu:20.04

LABEL maintainer="Reinhard Pointner <rednoah@filebot.net>"


# Grab build dependencies
RUN apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes sudo locales snapd curl jq squashfs-tools \
 && locale-gen en_US.UTF-8 \
 && rm -rvf /var/lib/apt/lists/*


# Grab core snap
RUN SNAP=core \
 && curl --silent --location --output $SNAP.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP \
 && unsquashfs -d /snap/$SNAP/current $SNAP.snap \
 && rm $SNAP.snap

# Grab core20 snap
RUN SNAP=core20 \
 && curl --silent --location --output $SNAP.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP \
 && unsquashfs -d /snap/$SNAP/current $SNAP.snap \
 && rm $SNAP.snap

# Grab gnome-3-38-2004-sdk snap
RUN SNAP=gnome-3-38-2004-sdk \
 && curl --silent --location --output $SNAP.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP \
 && unsquashfs -d /snap/$SNAP/current $SNAP.snap \
 && rm $SNAP.snap

# Grab snapcraft snap
RUN SNAP=snapcraft \
 && curl --silent --location --output $SNAP.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP \
 && unsquashfs -d /snap/$SNAP/current $SNAP.snap \
 && rm $SNAP.snap


# Create a snapcraft runner
RUN mkdir -p /snap/bin \
 && echo "#!/bin/sh" > /snap/bin/snapcraft \
 && snap_version="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft \
 && echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft \
 && chmod +x /snap/bin/snapcraft


# Pre-Install application dependencies
RUN apt-get update \
 && apt-get install --yes default-jdk openjfx libjna-java zenity xdg-utils mediainfo libchromaprint-tools unrar p7zip-full p7zip-rar mkvtoolnix atomicparsley \
 && rm -rvf /var/lib/apt/lists/*


# Set the proper environment
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/snap/bin:$PATH"
ENV SNAP="/snap/snapcraft/current"
ENV SNAP_NAME="snapcraft"
ENV SNAP_ARCH="amd64"


# Run snapcraft
WORKDIR /build


ENTRYPOINT ["/snap/bin/snapcraft"]

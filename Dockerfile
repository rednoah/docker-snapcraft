FROM ubuntu:20.04

LABEL maintainer="Reinhard Pointner <rednoah@filebot.net>"


# Install build dependencies
RUN set -eux \
 && apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes binutils binutils-common binutils-x86-64-linux-gnu gcc gcc-9 libasan5 libatomic1 libbinutils libc-dev-bin libc6-dev libcc1-0 libcrypt-dev libctf-nobfd0 libctf0 libgcc-9-dev libitm1 liblsan0 libquadmath0 libtsan0 libubsan1 linux-libc-dev make manpages manpages-dev \
 && apt-get install --yes sudo locales snapd curl jq squashfs-tools \
 && locale-gen en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# Install application dependencies
RUN set -eux \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install --install-recommends --yes default-jdk openjfx libjna-java zenity xdg-utils mediainfo libchromaprint-tools unrar p7zip-full p7zip-rar mkvtoolnix atomicparsley \
 && rm -rf /var/lib/apt/lists/*


# Grab core snap
RUN set -eux \
 && SNAP_NAME=core \
 && curl --silent --location --output $SNAP_NAME.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP_NAME" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP_NAME \
 && unsquashfs -d /snap/$SNAP_NAME/current $SNAP_NAME.snap \
 && rm $SNAP_NAME.snap

# Grab core20 snap
RUN set -eux \
 && SNAP_NAME=core20 \
 && curl --silent --location --output $SNAP_NAME.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP_NAME" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP_NAME \
 && unsquashfs -d /snap/$SNAP_NAME/current $SNAP_NAME.snap \
 && rm $SNAP_NAME.snap

# Grab gnome-3-38-2004-sdk snap
RUN set -eux \
 && SNAP_NAME=gnome-3-38-2004-sdk \
 && curl --silent --location --output $SNAP_NAME.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP_NAME" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP_NAME \
 && unsquashfs -d /snap/$SNAP_NAME/current $SNAP_NAME.snap \
 && rm $SNAP_NAME.snap

# Grab core18 snap (required by snapcraft)
RUN set -eux \
 && SNAP_NAME=core18 \
 && curl --silent --location --output $SNAP_NAME.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP_NAME" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP_NAME \
 && unsquashfs -d /snap/$SNAP_NAME/current $SNAP_NAME.snap \
 && rm $SNAP_NAME.snap

# Grab snapcraft snap
RUN set -eux \
 && SNAP_NAME=snapcraft \
 && curl --silent --location --output $SNAP_NAME.snap $(curl -H "X-Ubuntu-Series: 16" "https://api.snapcraft.io/api/v1/snaps/details/$SNAP_NAME" | jq ".download_url" -r) \
 && mkdir -p /snap/$SNAP_NAME \
 && unsquashfs -d /snap/$SNAP_NAME/current $SNAP_NAME.snap \
 && rm $SNAP_NAME.snap


# Create a snapcraft runner
RUN set -eux \
 && SNAP_VERSION="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" \
 && mkdir -p /snap/bin \
 && echo '#!/bin/sh' > /snap/bin/snapcraft \
 && echo "export SNAP_VERSION=$SNAP_VERSION" >> /snap/bin/snapcraft \
 && echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft \
 && chmod +x /snap/bin/snapcraft


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

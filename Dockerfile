FROM ubuntu:bionic


# Grab dependencies
RUN apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes curl jq squashfs-tools \ 
 && rm -rvf /var/lib/apt/lists/*


# Grab the core snap (for backwards compatibility) from the stable channel and unpack it in the proper place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core' | jq '.download_url' -r) --output core.snap \
 && mkdir -p /snap/core \
 && unsquashfs -d /snap/core/current core.snap


# Grab the core18 snap (which snapcraft uses as a base) from the stable channel and unpack it in the proper place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/core18' | jq '.download_url' -r) --output core18.snap \
 && mkdir -p /snap/core18 \
 && unsquashfs -d /snap/core18/current core18.snap


# Grab the snapcraft snap from the candidate channel and unpack it in the proper place.
RUN curl -L $(curl -H 'X-Ubuntu-Series: 16' 'https://api.snapcraft.io/api/v1/snaps/details/snapcraft?channel=candidate' | jq '.download_url' -r) --output snapcraft.snap \
 && mkdir -p /snap/snapcraft \
 && unsquashfs -d /snap/snapcraft/current snapcraft.snap


# Create a snapcraft runner.
RUN mkdir -p /snap/bin \
 && echo "#!/bin/sh" > /snap/bin/snapcraft \
 && snap_version="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)" && echo "export SNAP_VERSION=\"$snap_version\"" >> /snap/bin/snapcraft \
 && echo 'exec "$SNAP/usr/bin/python3" "$SNAP/bin/snapcraft" "$@"' >> /snap/bin/snapcraft \
 && chmod +x /snap/bin/snapcraft \
 && /snap/bin/snapcraft --version


# Generate locale and install dependencies.
RUN apt-get update \
 && apt-get dist-upgrade --yes \
 && apt-get install --yes snapd sudo locales \
 && locale-gen en_US.UTF-8 \
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
VOLUME /build
WORKDIR /build

ENTRYPOINT ["/snap/bin/snapcraft"]

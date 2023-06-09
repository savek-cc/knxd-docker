# knxd-docker

Build the container with specific version of KNXD.
This fork from michelmu/knxd-docker updates the alpine version and employs a multistage docker build to remove the image size from ~400MB down to ~40MB. Shrinking the image size by a factor of 10.

Alpine has an issue with the arg parser library - so you won't be able to run knxd using command line arguments (such as "-e 1.1.1").
Instead, you need to generate a knxd ini file (using "knxd_args") which is then copied into the container to be used by knxd.
The sample ini file included connects to an MDT IP-interface.

```bash
docker build -t savek-cc/knxd-docker --build-arg KNXD_VERSION=0.14.39 .
```

Run knxd in a small alpine docker container

```bash
docker run \
--name=knxd \
-p 6720:6720/tcp -p 3671:3671/udp \
--device=/dev/bus/usb:/dev/bus/usb:rwm \
--device=/dev/mem:/dev/mem:rw \
--device=/dev/knx:/dev/knx \
--cap-add=SYS_MODULE --cap-add=SYS_RAWIO \
--restart unless-stopped michelmu/knxd
```

Test the knx server by login to the container and run e.g.
`knxtool groupswrite ip:localhost 0/0/20 0`

This container provides an OpenCL execution environment for AMD graphics
cards. In order to work properly it requires access to the graphics
device and X.org.

Therefore you either have to run the container with `--priviledged` flag
or pass `/dev/ati` via `--device /dev/ati:dev/ati`.

    docker run --privileged \
               -e "DISPLAY=unix:0.0" \
               -v="/tmp/.X11-unix:/tmp/.X11-unix:rw"
               -t -i \
               cviebig/arch-build-ocl-catalyst:latest bash


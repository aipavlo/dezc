#!/bin/sh

docker pull python:3.13
docker run --rm -it --entrypoint bash python:3.13

# pip --version
### pip 25.3 from /usr/local/lib/python3.13/site-packages/pip (python 3.13)
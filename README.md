# logjam-libs

[![build](https://github.com/skaes/logjam-libs/actions/workflows/build.yml/badge.svg)](https://github.com/skaes/logjam-libs/actions/workflows/build.yml)


## About

logjam-libs provides methods to compile and install system libraries required by the
logjam-tools package.

The following packages are included:

* libzmq
* libczmq
* mongo-c-driver
* libbson
* json-c (0.12 patched)
* libsnappy
* lz4
* microhttpd


## Usage

### Installing packages locally

Calling script `./bin/install-libs --prefix=DIR` will download, compile and install
packages in the given directory, following standard Linux conventions. It defaults to
`/usr/local`, populating `/usr/local/bin` and `/usr/local/lib`.

Another good choice is `--prefix=/opt/logjam`, which makes sure that the logjam provided
libraries do not interfere with system versions.

If you are using Homebrew as your package manager on Mac OS it is recommended to install
the libraries with `--without-documentation` to prevent issues arising from trying to
validate XML files that can seemingly only be validated when `docbook-xsl-nons` is
installed.

If you want to get rid of the installed software, run
```
./bin/install-libs uninstall
```


### Travis pipeline

Upon code push, the Travis pipeline builds docker images and Debian packages for Ubuntu
Xenial and Ubuntu Bionic and uploads the images to [docker
hub](https://hub.docker.com/repository/docker/stkaes/logjam-libs) and the packages to
[railsexpress.de](https://railsexpress.de/packages/ubuntu).

Containers and packages are versioned. Edit `bin/version` to increment the version
number before you push to Github, if you want to build a new package.

The containers are:

* stkaes/logjam-libs:focal-`<version>`
* stkaes/logjam-libs:bionic-`<version>`
* stkaes/logjam-libs:xenial-`<version>`
* stkaes/logjam-libs:focal-usr-local-`<version>`
* stkaes/logjam-libs:bionic-usr-local-`<version>`
* stkaes/logjam-libs:xenial-usr-local-`<version>`

The packages are:

* focal/logjam-libs_`<version>`_amd64.deb
* bionic/logjam-libs_`<version>`_amd64.deb
* xenial/logjam-libs_`<version>`_amd64.deb
* focal/logjam-libs-usr-local_`<version>`_amd64.deb
* bionic/logjam-libs-usr-local_`<version>`_amd64.deb
* xenial/logjam-libs-usr-local_`<version>`_amd64.deb

The `usr-local` packages/containers are built with prefix `/usr/local`, the other ones use `/opt/logjam`.

## Building containers and packages locally

Run `make containers packages` to build docker images and Ubuntu packages.

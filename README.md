# Supported tags and respective `Dockerfile` links

* `6u41-jdk-centos`, `6u41-centos`, `6-jdk-centos`, `6-centos` [(6-jdk/centos/Dockerfile)][dockerfile-jdk6]
* `6u41-jre-centos`, `6-jre-centos` [(6-jre/centos/Dockerfile)][dockerfile-jre6]
* `7u131-jdk-centos`, `7u131-centos`, `7-jdk-centos`, `7-centos` [(7-jdk/centos/Dockerfile)][dockerfile-jdk7]
* `7u131-jre-centos`, `7-jre-centos` [(7-jre/centos/Dockerfile)][dockerfile-jre7]
* `8u121-jdk-centos`, `8u121-centos`, `8-jdk-centos`, `8-centos`, `jdk-centos`, `centos` [(8-jdk/centos/Dockerfile)][dockerfile-jdk8]
* `8u121-jre-centos`, `8-jre-centos`, `jre-centos` [(8-jre/centos/Dockerfile)][dockerfile-jre8]

![logo](https://raw.githubusercontent.com/antoineco/openjdk/master/logo.png)

# What is the `openjdk` image?

An extension of the official [`openjdk`][docker-openjdk] image with extra OS variants.

# How to use the `openjdk` image?

This image shares all its features with the official [`openjdk`][docker-openjdk] image.

# Image Variants

The `openjdk` images come in different flavors, each designed for a specific use case.

## Base operating system

### `openjdk:<version>-centos`

This image is based on the [CentOS](https://www.centos.org/) operating system, available in [the `centos` official image][docker-centos].

## Components

A tagging convention determines the version of the components distributed with the `openjdk` image.

### `<version α>-jre`

* OpenJDK release: **α**
* JRE (Java Runtime Environment) only

### `<version α>-jdk`

* OpenJDK release: **α**
* JDK (Java Development Kit) + JRE

# Maintenance

## Updating configuration

You can automatically update OpenJDK versions and regenerate the repository tree with:

```
./generate-dockerfiles.sh
```

## Updating library definition

After committing changes to the repository, regenerate the library definition file with:

```
./generate-bashbrew-library.sh >| openjdk
```

## Rebuilding images

All images in this repository can be rebuilt and tagged manually using [Bashbrew][bashbrew], the tool used for cloning, building, tagging, and pushing the Docker official images. To do so, simply call the `bashbrew` utility, pointing it to the included `openjdk` definition file as in the example below:

```
bashbrew --library . build openjdk
```

## Automated build pipeline

Any push to the upstream [`centos`][docker-centos] repository or to the source repository triggers an automatic rebuild of all the images in this repository. From a high perspective the automated build pipeline looks like the below diagram:

![Automated build pipeline][pipeline]


[dockerfile-jdk6]: https://github.com/antoineco/openjdk/blob/master/6-jdk/centos/Dockerfile
[dockerfile-jre6]: https://github.com/antoineco/openjdk/blob/master/6-jre/centos/Dockerfile
[dockerfile-jdk7]: https://github.com/antoineco/openjdk/blob/master/7-jdk/centos/Dockerfile
[dockerfile-jre7]: https://github.com/antoineco/openjdk/blob/master/7-jre/centos/Dockerfile
[dockerfile-jdk8]: https://github.com/antoineco/openjdk/blob/master/8-jdk/centos/Dockerfile
[dockerfile-jre8]: https://github.com/antoineco/openjdk/blob/master/8-jre/centos/Dockerfile
[banner]: https://raw.githubusercontent.com/antoineco/openjdk/master/logo.png
[docker-openjdk]: https://hub.docker.com/_/openjdk/
[docker-centos]: https://hub.docker.com/_/centos/
[bashbrew]: https://github.com/docker-library/official-images/blob/master/bashbrew/README.md
[pipeline]: https://raw.githubusercontent.com/antoineco/openjdk/master/build_pipeline.png

FROM centos:7

# A few problems with compiling Java from source:
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#       really hairy.

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.151-5.b12.el7_4.x86_64/jre

ENV JAVA_VERSION 8u151
ENV JAVA_CENTOS_VERSION 1.8.0.151-5.b12.el7_4

RUN set -x \
	&& yum install -y \
		java-1.8.0-openjdk-headless-"$JAVA_CENTOS_VERSION" which \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ] \
	&& yum clean all

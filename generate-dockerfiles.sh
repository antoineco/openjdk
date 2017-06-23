#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

declare -A centosVersions=(
	[6]='7'
	[7]='7'
	[8]='7'
)

centos-latest-version() {
	local package="$1"; shift
	local osVersion="$1"; shift
	local mirror='' repoDbUrl='' repoDbFile='' latestVersion=''

	mirror="$(wget -qO- "http://mirrorlist.centos.org/?release=$osVersion&arch=x86_64&repo=updates" | shuf -n1)"
	repoDbFile="$(mktemp)"
	repoDbUrl="$(wget -qO- "$mirror"repodata/repomd.xml | awk -F\" '/primary.sqlite.bz2/ {print $2}')"

	wget -qO- "${mirror}${repoDbUrl}" | bunzip2 >"$repoDbFile"
	latestVersion="$(
		sqlite3 "$repoDbFile" \
			"SELECT version, release FROM packages \
				WHERE name = '$package' AND arch = 'x86_64' \
				ORDER BY version DESC, release DESC LIMIT 1;" \
			| tr '|' '-'
	)"
	rm "$repoDbFile"

	echo "$latestVersion"
}

java-home-script() {
	cat <<'EOD'

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
EOD
}

for version in "${versions[@]}"; do
	javaVersion="$version" # "6-jdk"
	javaType="${javaVersion##*-}" # "jdk"
	javaVersion="${javaVersion%-*}" # "6"

	variant='centos'
	if [ -d "$version/$variant" ]; then
		centosVersion="${centosVersions[$javaVersion]}"
		centosPackage="java-1.${javaVersion}.0-openjdk"
		centosJavaHome="/usr/lib/jvm/${centosPackage}"

		case "$javaType" in
			jdk)
				# 'devel' == JDK
				centosPackage+="-devel"
				;;
			jre)
				# 'headless' == JRE
				[ "$javaVersion" -ne 6 ] && centosPackage+="-headless"
				;;
		esac

		centosPackageVersion="$(centos-latest-version "$centosPackage" "$centosVersion")" # 1.8.0.121-0.b13.el7_3
		centosFullVersion="${centosPackageVersion%%-*}" # 1.8.0.121

		if [ "$javaVersion" -eq 6 ]; then
			centosJavaHome+="-${centosFullVersion}.x86_64"
		else
			centosJavaHome+="-${centosPackageVersion}.x86_64"
		fi
		[ "$javaType" == "jre" ] && centosJavaHome+="/$javaType"

		centosFullVersion="${javaVersion}u${centosFullVersion##*.}" # 8u121

		echo "$version: $centosFullVersion (centos $centosPackageVersion)"

		cat > "$version/$variant/Dockerfile" <<-EOD
			FROM centos:$centosVersion

			# A few problems with compiling Java from source:
			#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
			#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
			#       really hairy.

			# Default to UTF-8 file.encoding
			ENV LANG C.UTF-8
		EOD

		java-home-script >> "$version/$variant/Dockerfile"

		cat >> "$version/$variant/Dockerfile" <<-EOD

			ENV JAVA_HOME $centosJavaHome
		EOD
		cat >> "$version/$variant/Dockerfile" <<-EOD

			ENV JAVA_VERSION $centosFullVersion
			ENV JAVA_CENTOS_VERSION $centosPackageVersion
		EOD
		cat >> "$version/$variant/Dockerfile" <<EOD

RUN set -x \\
	&& yum install -y \\
		${centosPackage}-"\$JAVA_CENTOS_VERSION" which \\
	&& [ "\$JAVA_HOME" = "\$(docker-java-home)" ] \\
	&& yum clean all
EOD

	fi

done

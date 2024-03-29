#!/bin/sh

PROJECT=$1

if [ x"$PROJECT" = x ]; then
	echo >&2 "Error: please specify project name. $0 [name]"
	exit 1
fi

# find what kind of platform we are on (GOOS) : linux, darwin, freebsd or windows
MACHINE_OS=`uname -s`

case "$MACHINE_OS" in
	Linux)
		GOOS=linux
		;;
	CYGWIN_*)
		GOOS=windows
		;;
	MINGW*)
		GOOS=windows
		;;
	Darwin*)
		GOOS=darwin
		;;
	FreeBSD)
		GOOS=freebsd
		;;
	*)
		echo >&2 "Error: unsupported platform $MACHINE_OS"
		exit 1
		;;
esac

# let the user override that value
if [ x"$MACHINE_ARCH" = x ]; then
	MACHINE_ARCH=`uname -m`
fi

case "$MACHINE_ARCH" in
	x86_64)
		GOARCH=amd64
		;;
	amd64)
		GOARCH=amd64
		;;
	i686)
		GOARCH=386
		;;
	i386)
		GOARCH=386
		;;
	powerpc)
		GOARCH=ppc
		;;
	armv7l)
		GOARCH=arm
		;;
	armv6l)
		GOARCH=arm
		;;
	aarch64)
		GOARCH=arm64
		;;
	riscv64)
		GOARCH=riscv64
		;;
	*)
		echo >&2 "Error: unsupported architecture $MACHINE_ARCH"
		exit 1
		;;
esac

MACHINE_FULL="${GOOS}_${GOARCH}"

echo "Grabbing version information for $PROJECT..."
if [ x"$CHANNEL" = x ]; then
	VERSION_INFO="$(curl -s -f "https://dist-go.tristandev.net/${PROJECT}/LATEST")"
else
	VERSION_INFO="$(curl -s -f "https://dist-go.tristandev.net/${PROJECT}/LATEST-${CHANNEL}")"
fi
CURL_RES=$?

if [ $CURL_RES != 0 ]; then
	echo >&2 "Error: Curl failed - did you input a valid project name?"
	exit $CURL_RES
fi

VERSION_DATE=`echo "$VERSION_INFO" | awk '{ print $1 }'`
VERSION_GIT=`echo "$VERSION_INFO" | awk '{ print $2 }'`
VERSION_PREFIX=`echo "$VERSION_INFO" | awk '{ print $3 }'`

# check available architectures
VERSION_ARCHS=`curl -s -f "https://dist-go.tristandev.net/${PROJECT}/${VERSION_PREFIX}.arch"`

CURL_RES=$?

if [ $CURL_RES != 0 ]; then
	echo >&2 "Error: Curl failed - did you input a valid project name?"
	exit $CURL_RES
fi

# check if our arch ($MACHINE_ARCH) is available
if [ `echo "$VERSION_ARCHS" | grep -c "$MACHINE_FULL"` -eq 0 ]; then
	echo >&2 "Error: project is not available for your platform ($MACHINE_FULL), only $VERSION_ARCHS"
	exit 1
fi

echo "Downloading version git $VERSION_GIT (dated $VERSION_DATE)..."

if [ "$GOOS" = "windows" ]; then
	OUTFILE="${PROJECT}.exe"
else
	OUTFILE="${PROJECT}"
fi

curl -s -f "https://dist-go.tristandev.net/${PROJECT}/${VERSION_PREFIX}/${PROJECT}_${MACHINE_FULL}.bz2" | bunzip2 >"${OUTFILE}~"
BZ_RES=$?

if [ $BZ_RES != 0 ]; then
	echo >&2 "Error: Failed to obtain correct version for this project"
	exit $CURL_RES
fi

chmod +x "${OUTFILE}~"
mv -f "${OUTFILE}~" "$OUTFILE"

#!/bin/sh
set -e

PROJECT=$1
if [ x"$ROOT" = x ]; then
	ROOT=""
fi

if [ x"$PROJECT" = x ]; then
	echo >&2 "Error: please specify project name. $0 [name]"
	exit 1
fi

# use /usr/sbin
cd "$ROOT/usr/sbin"

if [ -f "$PROJECT" ]; then
	echo >&2 "Error: project already installed?"
	exit 1
fi

# we use our own get.sh script
curl -s https://raw.githubusercontent.com/KarpelesLab/make-go/master/get.sh | /bin/sh -s "$PROJECT"

# let's install systemd script
echo "Installing systemd script ${PROJECT}..."

cat >$ROOT"/lib/systemd/system/${PROJECT}.service" <<EOF
[Unit]
Description=${PROJECT} daemon
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=30
StartLimitBurst=30

[Service]
Type=simple
ExecStart=/usr/sbin/${PROJECT}
Restart=always
RestartSec=5s
Environment=HOME=/root
$SVC_EXTRA

[Install]
WantedBy=multi-user.target
EOF

if [ x"$ROOT" = x ]; then
	systemctl enable "$PROJECT"
	if [ x"$SKIP_START" = x ]; then
		systemctl start "$PROJECT"
	fi
else
	# we cannot use systemctl because root may not be the same architecture
	# Created symlink /etc/systemd/system/multi-user.target.wants/daemonmaster.service → /lib/systemd/system/daemonmaster.service.
	ln -s "/lib/systemd/system/${PROJECT}.service" "${ROOT}/etc/systemd/system/multi-user.target.wants/${PROJECT}.service"
	echo "Created symlink ${ROOT}/etc/systemd/system/multi-user.target.wants/${PROJECT}.service → /lib/systemd/system/${PROJECT}.service"
fi

#!/bin/sh
set -e

PROJECT=$1

if [ x"$PROJECT" = x ]; then
	echo >&2 "Error: please specify project name. $0 [name]"
	exit 1
fi

# use /usr/sbin
cd /usr/sbin

if [ -f "$PROJECT" ]; then
	echo >&2 "Error: project already installed?"
	exit 1
fi

# we use our own get.sh script
curl -s https://raw.githubusercontent.com/KarpelesLab/make-go/master/get.sh | /bin/sh -s "$PROJECT"

# let's install systemd script
echo "Installing systemd script ${PROJECT}..."

cat >"/lib/systemd/system/${PROJECT}.service" <<EOF
[Unit]
Description=${PROJECT} daemon
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
Type=simple
ExecStart=/usr/sbin/${PROJECT}
Restart=on-failure
RestartSec=5s
Environment=HOME=/root
$SVC_EXTRA

[Install]
WantedBy=multi-user.target
EOF

systemctl start "$PROJECT"
systemctl enable "$PROJECT"

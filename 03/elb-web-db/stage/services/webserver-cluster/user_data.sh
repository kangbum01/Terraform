#!/bin/bash
set -euxo pipefail

dnf install -y httpd

cat > /var/www/html/index.html <<EOF
<h1>db IP: ${dbaddress}</h1>
<p>db Port: ${dbport}</p>
<p>db name: ${dbname}</p>
EOF

systemctl enable --now httpd

#!/bin/sh

echo "Creating Musl Fake ldconfig"

cat > /usr/sbin/ldconfig << EOF
#!/bin/sh
exit 0
EOF

chmod -v +x /usr/sbin/ldconfig

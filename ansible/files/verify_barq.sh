#!/bin/bash
echo "===== Part 1 – Log Setup ====="
echo "Log directory contents:"
ls -l /var/log/barq/
echo
echo "Check log-lite.sh:"
ls -l /usr/local/bin/log-lite.sh
echo
echo "Check cron for log-lite.sh:"
sudo crontab -l | grep log-lite.sh || echo "No cron job found"
echo
echo "===== Part 2 – Java App Deployment ====="
echo "Release folders:"
ls -l /opt/barq/releases/
echo "Current symlink:"
ls -l /opt/barq/current
echo
echo "BARQ service status:"
sudo systemctl status barq --no-pager
echo
echo "Last 10 log entries:"
tail -n 10 /var/log/barq/barq.log
echo
echo "===== Part 3 – TLS Certificate Report ====="
echo "Check cert-lite.sh:"
ls -l /usr/local/bin/cert-lite.sh
echo
echo "Run script manually:"
sudo /usr/local/bin/cert-lite.sh
echo "Report contents:"
cat /var/reports/cert-lite.txt
echo
echo "Check cron for cert-lite.sh:"
sudo crontab -l | grep cert-lite.sh || echo "No cron job found"

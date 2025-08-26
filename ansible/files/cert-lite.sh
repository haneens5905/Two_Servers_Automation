#!/bin/bash

# File where the report will be stored
REPORT_FILE="/var/reports/cert-lite.txt"

# Ensure the directory exists
mkdir -p /var/reports

# Write the header (overwrite the file each run)
echo "cert_name | NotAfter_date | days_remaining" > "$REPORT_FILE"

# Loop through each .crt file and append info
for CERT in /etc/ssl/patrol/*.crt; do
    # Get the certificate name
    CERT_NAME=$(basename "$CERT")
    
    # Get the expiration date in "Not After" format
    NOT_AFTER=$(openssl x509 -enddate -noout -in "$CERT" | cut -d= -f2)
    
    # Calculate remaining days
    END_DATE=$(date -d "$NOT_AFTER" +%s)
    NOW=$(date +%s)
    DAYS_LEFT=$(( (END_DATE - NOW) / 86400 ))
    
    # Append the info to the report file
    printf "%s | %s | %s\n" "$CERT_NAME" "$NOT_AFTER" "$DAYS_LEFT" >> "$REPORT_FILE"
done


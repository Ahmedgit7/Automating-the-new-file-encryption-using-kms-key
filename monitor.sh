#!/bin/bash

# Define the directory to monitor
directory="/home/ec2-user/testscript"

# Define the AWS KMS key ID or ARN
kms_key="add your kms key here"

# Monitor the directory for new files
inotifywait -m -r -e create --format '%w%f' "$directory" | while read newfile
do
    # Check if the new file is not already encrypted
    if [[ "$newfile" != *.kms.enc ]]; then
        # Encrypt the new file using AWS KMS and suppress error output
        aws kms encrypt --key-id "$kms_key" --plaintext "fileb://$newfile" --output text --query CiphertextBlob > "$newfile.kms.enc" 2>/dev/null

        # Display a message indicating that the file was encrypted
        echo "File encrypted: $newfile.kms.enc"

        # Remove the original file after encryption
        rm -f "$newfile"
    fi
done


#!/bin/bash

# Check if the .ftp_config file already exists
if [[ -f ./.ftp_config ]]; then
  echo ".ftp_config file already exists, will not be created anew."
else
  # Copy the example config file to .ftp_config
  cp ./vendor/dgvirtual/deploy-via-ftp/src/ftp-config.example .ftp_config
  echo ".ftp_config file created from ftp-config.example."
fi

# Ask the user if they want to add .ftp_config to .gitignore
if [[ -f ./.gitignore ]]; then
  read -p "Do you want to add .ftp_config to .gitignore? (y/n): " add_to_gitignore
  if [[ "$add_to_gitignore" == "y" || "$add_to_gitignore" == "Y" ]]; then
    if ! grep -qxF '.ftp_config' .gitignore; then
      echo '.ftp_config' >> .gitignore
      echo ".ftp_config added to .gitignore."
    else
      echo ".ftp_config is already in .gitignore."
    fi
  fi
fi

# Instruct the user to edit the .ftp_config file
echo "Please edit the .ftp_config file with your FTP details, then rerun the deploy script."

exit 0
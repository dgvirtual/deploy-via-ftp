#!/bin/bash

# Check if .ftp_config file exists in the current directory
if [[ ! -f ./.ftp_config ]]; then
  echo ".ftp_config file not found."
  read -p "Do you want to create the .ftp_config file from the example? (y/n): " create_config
  if [[ "$create_config" == "y" || "$create_config" == "Y" ]]; then
    ./vendor/dgvirtual/deploy-via-ftp/src/install.sh
  else
    echo "Cannot proceed without .ftp_config. Exiting."
    exit 1
  fi
fi

# Retrieve all variables for server, protocol, and directories
source ./.ftp_config

# Base directory (where the script is executed)
BASE_DIR="$(pwd)"

# Function to synchronize a directory using lftp
sync_dir() {
  local local_dir="$1"
  local remote_dir="$2"
  local excludes="$3"  # Exclude patterns

  local full_local_path="$BASE_DIR/$local_dir"
  if [[ ! -d "$full_local_path" ]]; then
    echo "Error: Local directory '$full_local_path' does not exist."
    return 1
  fi
  echo "Synchronizing directory: '$full_local_path' to '$remote_dir'"

  if [[ "$PROTOCOL" == "ftps" ]]; then
    lftp -f "
    set ftp:ssl-force true
    set ftp:ssl-protect-data true
    open $SERVER
    user $USERNAME $PASSWORD
    lcd $BASE_DIR
    mirror -c --continue --reverse --delete --verbose $excludes $local_dir $remote_dir
    bye
    "
  else
    lftp -f "
    open $SERVER
    user $USERNAME $PASSWORD
    lcd $BASE_DIR
    mirror -c --continue --reverse --delete --verbose $excludes $local_dir $remote_dir
    bye
    "
  fi

  if [[ $? -eq 0 ]]; then
    echo "Successfully synchronized '$full_local_path' to '$remote_dir'"
  else
    echo "Error: Synchronization of '$full_local_path' failed."
    exit 1
  fi
}

# Function to upload a single file using curl
upload_single_file() {
  local local_file="$1"
  local full_local_path="$BASE_DIR/$local_file"
  if [[ ! -f "$full_local_path" ]]; then
    echo "Error: Local file '$full_local_path' does not exist."
    return 1
  fi

  # Automatically determine the remote path based on the local file path
  local remote_file="/${local_file}"

  if [[ "$local_file" == app/* ]]; then
    remote_file="$REMOTE_APP/${local_file#app/}"
  elif [[ "$local_file" == vendor/* ]]; then
    remote_file="$REMOTE_VENDOR/${local_file#vendor/}"
  elif [[ "$local_file" == public/* ]]; then
    remote_file="$REMOTE_PUBLIC_HTML/${local_file#public/}"
  else
    echo "Error: Could not determine remote directory for '$local_file'."
    return 1
  fi

  if [[ "$PROTOCOL" == "ftps" ]]; then
    CURL_OPTS="--ftp-ssl-reqd --ftp-create-dirs --ftp-pasv"
  else
    CURL_OPTS="--ftp-pasv"
  fi

  curl $CURL_OPTS --ftp-create-dirs -T "$full_local_path" --user "$USERNAME:$PASSWORD" ftp://$SERVER:$PORT$remote_file

  if [[ $? -eq 0 ]]; then
    echo "Successfully uploaded '$full_local_path' to '$remote_file'"
  else
    echo "Error: Upload of '$full_local_path' failed."
    exit 1
  fi
}
# Check for arguments and call the appropriate function
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 (app|vendor|public)"
  echo    "or: $0 onefile [local_path]"
  
  echo "  app: Synchronize app directory only."
  echo "  vendor: Synchronize vendor directory only."
  echo "  public: Synchronize public_html directory only."
  echo "  The above arguments can be used together,"
  echo "  e.g.:"
  echo "  ./deploy.sh app vendor"
  echo "  onefile [local_path]: Upload a single file using curl."
  echo "  e.g.:"
  echo "  ./deploy.sh onefile app/Controllers/Test.php"
  exit 1
fi

# Process each argument provided to the script
for target in "$@"; do
  case $target in
    app)
      echo 'Syncing app folder...'
      sync_dir "$LOCAL_APP" "$REMOTE_APP" "$APP_EXCLUDE_GLOBS"
      ;;
    vendor)
      echo 'Remove vendor dev dependencies...'
      composer install --no-dev
      echo 'Syncing vendor folder...'
      sync_dir "$LOCAL_VENDOR" "$REMOTE_VENDOR" "$VENDOR_EXCLUDE_GLOBS"
      echo 'Restore vendor dev dependencies...'
      composer install
      ;;
    public)
      echo 'Syncing public folder...'
      sync_dir "$LOCAL_PUBLIC_HTML" "$REMOTE_PUBLIC_HTML" "$PUBLIC_EXCLUDE_GLOBS"
      ;;
    onefile)
      if [[ $# -lt 2 ]]; then
        echo "Usage: $0 onefile [local_path]"
        exit 1
      fi
      echo 'Uploading single file...'
      upload_single_file "$2"
      shift # Move to the next argument (skip the file path)
      ;;
    *)
      echo "Invalid argument: '$target'"
      exit 1
      ;;
  esac
done

exit 0

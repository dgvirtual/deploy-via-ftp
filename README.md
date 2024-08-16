# Deploy via FTP

This is a simple script package for deploying PHP projects to a shared hosting server via FTP or FTPS. It allows you to synchronize directories or upload individual files using `lftp` and `curl`.

## Author

**Name**: Donatas Glodenis  
**Email**: [dg@lapas.info](mailto:dg@lapas.info)

## Dependencies

This project has the following dependencies:

- **lftp**: Used for synchronizing directories.
- **curl**: Used for uploading individual files.
- **composer**: Required for installing this package and updating the vendor directory before and after
deployment.

**Note**: The project has been tested on **Ubuntu 24.04 LTS**.

Ensure that `lftp`, `curl`, and `composer` are installed and accessible in your system's `PATH`.

## Installation

You can install this package via Composer by adding the following configuration to your `composer.json` file:

```json
{
    "repositories": [
        {
            "type": "vcs",
            "url": "https://github.com/dgvirtual/deploy-via-ftp"
        }
    ],
    "require": {
        "dgvirtual/deploy-via-ftp": "dev-master"
    },
    "scripts": {
        "deploy": "./vendor/dgvirtual/deploy-via-ftp/src/deploy.sh"
    }
}
```

Then, run the following command in your project directory:

```bash
composer install
```

This will install the `deploy-via-ftp` package from your GitHub repository and make the deployment script available in your project.

## Usage

### Synchronizing Directories

You can use the following commands to synchronize directories with your remote FTP server:

```bash
composer deploy app
composer deploy vendor
composer deploy public
```

You can also combine multiple directories in a single command:

```bash
composer deploy app vendor
```

#### Available Arguments:

- **app**: Synchronize the `app` directory only.
- **vendor**: Synchronize the `vendor` directory only.
- **public**: Synchronize the `public_html` directory only.

### Uploading a Single File

To upload a single file, use the following command:

```bash
composer deploy onefile [local_path]
```

**Example:**

```bash
composer deploy onefile app/Controllers/Test.php
```

This will upload `app/Controllers/Test.php` to the corresponding location on your FTP server.
The remote path will be determined based on the local path.

## Configuration

Before you can use the deployment script, you need to configure your FTP settings.

1. On the first run, if the `.ftp_config` file is missing in the main project directory, the script will prompt you to create it by running an `install.sh` script.
2. The `install.sh` script will:
   - Copy `ftp-config.example` to `.ftp_config`.
   - Optionally add `.ftp_config` to your `.gitignore` file.
   - Instruct you to edit `.ftp_config` with your FTP credentials.

### Example `.ftp_config`:

```bash
# .ftp_config
USERNAME="myname"
PASSWORD="mySecretPass"
PROTOCOL="ftps"  # or "ftp"
PORT=21
SERVER="ftp.example.com"

# Remote directories
REMOTE_APP="/myproject/app"
REMOTE_VENDOR="/myproject/vendor"
REMOTE_PUBLIC_HTML="/public_html"

# Exclusion patterns
APP_EXCLUDE_GLOBS=""
VENDOR_EXCLUDE_GLOBS=""
PUBLIC_EXCLUDE_GLOBS="--exclude-glob='uploads/*' --exclude-glob='index.php'"

# Local directories
LOCAL_APP="app"
LOCAL_VENDOR="vendor"
LOCAL_PUBLIC_HTML="public"
```

Edit this file with your FTP credentials and paths as needed.

## Notes

- The script assumes that your project follows a structure where directories like `app`, `vendor`, and `public_html` are located in the base directory.
- Make sure to review the exclusion patterns in the `.ftp_config` file and adjust them to suit your project.

If you have any issues or need further assistance, feel free to contact the author at [dg@lapas.info](mailto:dg@lapas.info).

---

This `README.md` file provides clear instructions for installing, configuring, and using the `deploy-via-ftp` script, tailored specifically for your needs.
# Samloader Actions - GNSF Upgraded

This GitHub Actions workflow downloads Samsung firmware using the superior **GNSF** (GetNewSamsungFirmware) tool and extracts boot images for Magisk patching.

## Features

- ✅ Uses the improved `gnsf.py` tool for better firmware downloads from Samsung servers
- ✅ Simplified input - only 2 parameters needed
- ✅ Automatically extracts boot, init_boot, vbmeta, recovery, and dtbo images
- ✅ Creates ready-to-use Magisk patch packages
- ✅ Uploads to DigitalOcean Spaces automatically

## Usage

### 1. Run the Workflow

Go to **Actions** → **Create a zip for Magisk** → **Run workflow**

### 2. Provide Inputs

You need to provide **2 inputs**:

#### Input 1: GNSF Command (`gnsf_command`)
The full gnsf.py command **without the actual IMEI** (use `YOUR_IMEI` as placeholder).

**Example:**
```bash
./gnsf.py -m SM-X135G -r XFV -i YOUR_IMEI download -v "X135GDXU1AYH5/X135GOJM1AYI1/X135GDXU1AYH5/X135GDXU1AYH5" -O ./downloads
```

**Format explained:**
- `-m SM-X135G` - Your device model
- `-r XFV` - Region code (CSC)
- `-i YOUR_IMEI` - Keep as `YOUR_IMEI` (will be replaced automatically)
- `download` - Command to download
- `-v "VERSION_STRING"` - The firmware version (4 parts separated by `/`)
- `-O ./downloads` - Output directory (keep as `./downloads`)

#### Input 2: IMEI (`imei`)
Your device IMEI number (15 digits).

**Example:**
```
123456789012345
```

### 3. How to Find Your Firmware Version

You can use gnsf.py locally to check for available updates:

```bash
./gnsf.py -m YOUR_MODEL -r YOUR_REGION -i YOUR_IMEI checkupdate
```

This will return the latest version string that you can use in the download command.

## Output Files

The workflow creates **2 files** in your DigitalOcean Spaces:

1. **`{model}-{version}.zip`** - Original firmware file
2. **`{model}-{version}-magisk.tar`** - Extracted boot images ready for Magisk patching

### Extracted Images

The Magisk tar file may contain (depending on device):
- `boot.img` - Main boot image
- `init_boot.img` - Init boot image (for newer devices)
- `vbmeta.img` - Verified boot metadata
- `recovery.img` - Recovery image
- `dtbo.img` - Device tree blob overlay

## Examples

### Example 1: Galaxy Tab A9 (SM-X115)
```
GNSF Command:
./gnsf.py -m SM-X115 -r ILO -i YOUR_IMEI download -v "X115XXU3AXI1/X115OXM3AXI1/X115XXU3AXH1/X115XXU3AXH1" -O ./downloads

IMEI:
123456789012345
```

### Example 2: Galaxy S24 Ultra (SM-S928B)
```
GNSF Command:
./gnsf.py -m SM-S928B -r XFV -i YOUR_IMEI download -v "S928BXXU2AXJ2/S928BOXM2AXJ2/S928BXXU2AXJ1/S928BXXU2AXJ1" -O ./downloads

IMEI:
987654321098765
```

## Configuration

### Required Secrets

Make sure you have these secrets configured in your repository:

- `DO_SPACES_KEY` - DigitalOcean Spaces access key
- `DO_SPACES_SECRET` - DigitalOcean Spaces secret key
- `DO_BUCKET_PATH_FULL` - Full S3 path (e.g., `s3://your-bucket/firmware/`)

## Technical Details

### GNSF vs Samloader

**GNSF** (gnsf.py) is superior to the old Samloader because:
- More reliable firmware downloads
- Better error handling
- Supports newer Samsung authentication methods
- Actively maintained
- Faster download speeds

### Workflow Steps

1. **Setup** - Installs Python, required tools (lz4, simg2img, etc.)
2. **Download** - Uses gnsf.py to download encrypted firmware
3. **Decrypt** - Automatically decrypts the firmware (gnsf handles this)
4. **Extract** - Unzips firmware and extracts AP partition
5. **Parse** - Extracts boot images from AP tar
6. **Package** - Creates tar files for Magisk
7. **Upload** - Uploads to DigitalOcean Spaces

## Troubleshooting

### Invalid IMEI
Make sure your IMEI is exactly 15 digits and matches your device model.

### Version not found
The version string might be incorrect. Run `checkupdate` locally first to get the exact version string.

### Download failed
- Check if the model/region combination is correct
- Some regions might not have the specific version available
- Try a different region code (CSC)

## License

This project uses:
- GNSF by [keklick1337](https://github.com/keklick1337/gnsf)
- Original Samloader Actions by [@ravindu644](https://github.com/ravindu644)

## Credits

- **GNSF Tool** - Vladislav Tislenko (keklick1337)
- **Original Samloader Actions** - @ravindu644
- **Upgrade & Integration** - Moshe Shor

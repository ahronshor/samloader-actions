#!/bin/bash

# GNSF wrapper script for GitHub Actions
# This script handles the firmware download and extraction using gnsf.py

clear
export WDIR=$(pwd)
chmod +755 -R *
source "$WDIR/res/colors"

echo -e "\n${BLUE}GNSF Firmware Downloader - Upgraded by Moshe${RESET}\n"

# Replace YOUR_IMEI in the gnsf command with the actual IMEI
FINAL_COMMAND=$(echo "$GNSF_COMMAND" | sed "s/YOUR_IMEI/${IMEI}/g")

echo -e "${MINT_GREEN}[+] Running command: ${FINAL_COMMAND}${RESET}\n"

# Extract model name from the command for file naming
MODEL=$(echo "$GNSF_COMMAND" | grep -oP '(?<=-m )\S+')

# Extract version - support both quoted and unquoted formats
# Try with quotes first, then without
VERSION=$(echo "$GNSF_COMMAND" | grep -oP '(?<=-v ")[^"]+' | cut -d'/' -f1)
if [ -z "$VERSION" ]; then
    # Try without quotes
    VERSION=$(echo "$GNSF_COMMAND" | grep -oP '(?<=-v )\S+' | cut -d'/' -f1)
fi

if [ -z "$MODEL" ]; then
    echo -e "${RED}[x] Could not extract MODEL from command${RESET}\n"
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo -e "${RED}[x] Could not extract VERSION from command${RESET}\n"
    echo -e "${YELLOW}[i] Command was: $GNSF_COMMAND${RESET}\n"
    exit 1
fi

# Convert model to lowercase for filename
MODEL_NAME=$(echo "$MODEL" | tr '[:upper:]' '[:lower:]')

echo -e "====================================\n"
echo -e "${LIGHT_YELLOW}[+] Model: ${BOLD_WHITE}${MODEL}${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] Model Name: ${BOLD_WHITE}${MODEL_NAME}${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] IMEI: ${BOLD_WHITE}${IMEI:0:9}XXXXXX${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] Version: ${BOLD_WHITE}${VERSION}${RESET}\n${LIGHT_YELLOW}${RESET}"
echo -e "====================================\n"

# Clean up previous runs
if [ -d "$WDIR/downloads" ]; then
    rm -rf downloads output Magisk Dist
fi

if [ ! -d "$WDIR/Dist" ]; then
    mkdir -p downloads output Magisk Dist
fi

# Execute the gnsf.py command
echo -e "${MINT_GREEN}[+] Downloading firmware...${RESET}\n"
if ! eval "$FINAL_COMMAND"; then
    echo -e "\n${RED}[x] GNSF download failed${RESET}\n"
    exit 1
fi

echo -e "\n${MINT_GREEN}[+] Download completed successfully${RESET}\n"

# Find the downloaded firmware file in downloads directory
# gnsf.py downloads and auto-decrypts, resulting in a .zip or .tar.md5 file
FIRMWARE_FILE=$(find downloads -type f \( -name "*.zip" -o -name "*.tar.md5" \) | head -n 1)

if [ -z "$FIRMWARE_FILE" ]; then
    echo -e "${RED}[x] No firmware file found in downloads directory${RESET}\n"
    echo -e "${YELLOW}[i] Directory contents:${RESET}"
    ls -lah downloads/
    exit 1
fi

echo -e "${MINT_GREEN}[+] Found firmware: ${FIRMWARE_FILE}${RESET}\n"

# Determine file extension for proper naming
if [[ "$FIRMWARE_FILE" == *.zip ]]; then
    FILE_EXT="zip"
elif [[ "$FIRMWARE_FILE" == *.tar.md5 ]]; then
    FILE_EXT="tar.md5"
else
    FILE_EXT="zip"
fi

# Copy original firmware to Dist
cp "$FIRMWARE_FILE" "$WDIR/Dist/${MODEL_NAME}-${VERSION}.${FILE_EXT}"

# Extract the firmware
cd "$WDIR/downloads"
echo -e "\n${MINT_GREEN}[+] Extracting firmware...${RESET}\n"

# Check file type and extract accordingly
BASENAME_FILE=$(basename "$FIRMWARE_FILE")

if [[ "$BASENAME_FILE" == *.zip ]]; then
    echo -e "${MINT_GREEN}[i] Extracting ZIP file: ${BASENAME_FILE}${RESET}\n"
    unzip -q "$BASENAME_FILE"
elif [[ "$BASENAME_FILE" == *.tar.md5 ]]; then
    echo -e "${MINT_GREEN}[i] Extracting TAR.MD5 file: ${BASENAME_FILE}${RESET}\n"
    tar -xf "$BASENAME_FILE"
elif [[ "$BASENAME_FILE" == *.tar ]]; then
    echo -e "${MINT_GREEN}[i] Extracting TAR file: ${BASENAME_FILE}${RESET}\n"
    tar -xf "$BASENAME_FILE"
fi

# Extract AP tar file if exists
for file in AP*.tar.md5; do
    if [ -f "$file" ]; then
        echo -e "${MINT_GREEN}[+] Extracting AP file: ${file}${RESET}\n"
        tar -xf "$file"
    fi
done

# Decompress LZ4 files if any
files=$(find . -name "*.lz4")
if [ -n "$files" ]; then
    echo -e "${MINT_GREEN}[i] Decompressing LZ4 files...${RESET}\n"
    lz4 -m *.lz4 > /dev/null 2>&1
    rm -f *.lz4
fi

# Extract boot and init_boot images
echo -e "${MINT_GREEN}[+] Extracting boot images...${RESET}\n"

cd "$WDIR/downloads"
export BASE_TAR_NAME="Magisk-Patch-Me-${MODEL}.tar"

# Copy required boot images
mkdir -p "$WDIR/output/${MODEL}"
EXTRACTED_FILES=()

if [ -f "boot.img" ]; then
    cp boot.img "$WDIR/output/${MODEL}/"
    EXTRACTED_FILES+=("boot.img")
    echo -e "${LIGHT_GREEN}[✓] Extracted boot.img${RESET}"
fi

if [ -f "init_boot.img" ]; then
    cp init_boot.img "$WDIR/output/${MODEL}/"
    EXTRACTED_FILES+=("init_boot.img")
    echo -e "${LIGHT_GREEN}[✓] Extracted init_boot.img${RESET}"
fi

if [ -f "vbmeta.img" ]; then
    cp vbmeta.img "$WDIR/output/${MODEL}/"
    EXTRACTED_FILES+=("vbmeta.img")
    echo -e "${LIGHT_GREEN}[✓] Extracted vbmeta.img${RESET}"
fi

if [ -f "recovery.img" ]; then
    cp recovery.img "$WDIR/output/${MODEL}/"
    EXTRACTED_FILES+=("recovery.img")
    echo -e "${LIGHT_GREEN}[✓] Extracted recovery.img${RESET}"
fi

if [ -f "dtbo.img" ]; then
    cp dtbo.img "$WDIR/output/${MODEL}/"
    EXTRACTED_FILES+=("dtbo.img")
    echo -e "${LIGHT_GREEN}[✓] Extracted dtbo.img${RESET}"
fi

# Check if we extracted any files
if [ ${#EXTRACTED_FILES[@]} -eq 0 ]; then
    echo -e "${RED}[x] No boot images found to extract${RESET}\n"
    exit 1
fi

# Create tar archive for Magisk (all boot images)
cd "$WDIR/output/${MODEL}"
tar -cf "../${BASE_TAR_NAME}" "${EXTRACTED_FILES[@]}"
cd "$WDIR/output"

# Create final tar with model name for Magisk
export FINAL_TAR_NAME="${MODEL_NAME}-${VERSION}-magisk.tar"
tar -cf "${FINAL_TAR_NAME}" "${MODEL}"

# Move Magisk tar to Dist directory
mv "${FINAL_TAR_NAME}" "$WDIR/Dist/"

echo -e "\n${LIGHT_YELLOW}[✓] Created Magisk package: ${FINAL_TAR_NAME}${RESET}\n"

# Create simple boot tar (8-f90 format) with boot and/or init_boot
echo -e "${MINT_GREEN}[+] Creating simplified boot package...${RESET}\n"

cd "$WDIR/output/${MODEL}"

# Collect boot files (include both boot.img and init_boot.img if they exist)
BOOT_FILES=()

if [ -f "init_boot.img" ]; then
    BOOT_FILES+=("init_boot.img")
    echo -e "${LIGHT_GREEN}[i] Including init_boot.img${RESET}"
fi

if [ -f "boot.img" ]; then
    BOOT_FILES+=("boot.img")
    echo -e "${LIGHT_GREEN}[i] Including boot.img${RESET}"
fi

# Check if we have at least one boot file
if [ ${#BOOT_FILES[@]} -eq 0 ]; then
    echo -e "${RED}[x] No boot.img or init_boot.img found${RESET}\n"
    exit 1
fi

# Create simple tar with boot file(s)
SIMPLE_TAR_NAME="${MODEL_NAME}-${VERSION}-8-f90.tar"
tar -cf "../${SIMPLE_TAR_NAME}" "${BOOT_FILES[@]}"
cd "$WDIR/output"

# Move simple tar to Dist directory
mv "${SIMPLE_TAR_NAME}" "$WDIR/Dist/"

echo -e "${LIGHT_YELLOW}[✓] Created simple boot package: ${SIMPLE_TAR_NAME}${RESET}\n"
echo -e "${LIGHT_YELLOW}[✓] Original firmware: ${MODEL_NAME}-${VERSION}.${FILE_EXT}${RESET}\n"

# Clean up temporary files to save space
echo -e "${MINT_GREEN}[+] Cleaning up temporary files...${RESET}\n"
rm -rf "$WDIR/downloads"
rm -rf "$WDIR/output"
echo -e "${LIGHT_GREEN}[✓] Cleanup completed${RESET}\n"

# List all created files
echo -e "${MINT_GREEN}[+] Files ready for upload:${RESET}\n"
ls -lh "$WDIR/Dist/"

# Show disk space
echo -e "\n${MINT_GREEN}[+] Disk space:${RESET}\n"
df -h | grep -E "Filesystem|/$"

echo -e "\n${LIGHT_GREEN}[✓] All done!${RESET}\n"

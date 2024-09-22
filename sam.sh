#!/bin/bash

# Copyright (c) [2023] [@ravindu644]

clear
export WDIR=$(pwd)
chmod +755 -R *
source "$WDIR/res/colors"

echo -e "\n${BLUE}Samloader Actions - By @ravindu644${RESET}\n"
echo -e "\n\t${UNBOLD_GREEN}Installing requirements...${RESET}\n"

sudo apt install simg2img lz4 openssl python3-pip -y > /dev/null 2>&1
echo -e "${MAGENTA}\n[+] Success..! ${RESET}\n"

echo -e "${UNBOLD_GREEN}[+] Installing Samloader...${RESET}\n"
if [ ! -f "$WDIR/.samloader" ]; then
    cd ~ ; pip3 install git+https://github.com/martinetd/samloader.git --no-warn-script-location > /dev/null 2>&1
    echo "1" > "$WDIR/.samloader"
    cd "$WDIR"
else
    echo -e "${RED}[x] Existing Installation found..!\n${RESET}"
fi

export BASE_TAR_NAME="Magisk-Patch-Me-${MODEL}.tar"

echo -e "====================================\n"
echo -e "${LIGHT_YELLOW}[+] Model: ${BOLD_WHITE}${MODEL}${RESET}\n${LIGHT_YELLOW}"
echo -e "${LIGHT_YELLOW}[+] IMEI: ${BOLD_WHITE}${IMEI:0:9}XXXXXX${RESET}\n${LIGHT_YELLOW}"
#echo -e "${LIGHT_YELLOW}[+] CSC: ${BOLD_WHITE}${CSC}${RESET}\n${LIGHT_YELLOW}${RESET}"
echo -e "====================================\n"

CSV_URL="https://raw.githubusercontent.com/zacharee/SamloaderKotlin/853438372672f6863d2d55914bd0a016c58ba064/common/src/commonMain/moko-resources/files/cscs.csv"

# Read the CSV and loop through each line (ignoring the header)
curl -s "$CSV_URL" | while IFS=, read -r csc_name csc_code; do
    if [[ "$csc_name" == "csc" ]]; then
        continue  # Skip header
    fi

    echo -e "${MINT_GREEN}[+] Fetching Latest Firmware for CSC: ${csc_name} ...\n${RESET}"
    if ! VERSION=$(python3 -m samloader -m "${MODEL}" -r "${csc_name}" -i "${IMEI}" checkupdate 2>/dev/null); then
        echo -e "\n${RED}[x] Model or region not found for ${csc_name}  (403) ${RESET}\n"
    else
        CSC=$csc_name
        echo -e "${LIGHT_YELLOW}[i] Update found for ${csc_name}: ${BOLD_WHITE}${VERSION}${RESET}\n"
        break  # Exit the loop after finding the first update
    fi

done 

echo -e "${MINT_GREEN}[+] Attempting to Download...\n ${RESET}"

if [  -d "$WDIR/Downloads" ];then
    rm -rf Downloads output Magisk Dist
fi

if [ ! -d "$WDIR/Downloads" ];then
    mkdir Downloads output Magisk Dist
fi

if ! python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" download -v "${VERSION}" -O "$WDIR/Downloads" ; then
    source "$WDIR/res/colors"
    echo -e "\n${RED}[x] Something Strange Happened :( ${RESET}"
    echo -e "\n${RED}[?] Did you enter the correct IMEI for your device model..? 👀 ${RESET} \n"
    exit 1
fi

echo -e "\n${MINT_GREEN}[+] Decrypting...\n${RESET}\n"
FILE="$(ls $WDIR/Downloads/*.enc*)"
if ! python3 -m samloader -m "${MODEL}" -r "${CSC}" -i "${IMEI}" decrypt -v "${VERSION}" -i "$FILE" -o "$WDIR/Downloads/firmware.zip"; then
    echo -e "\n${RED}[x] Something Strange Happened :( ${RESET}\n"
    exit 1
fi

rm "${FILE}"

#### Begin of core worker ####

bash "$WDIR/tools/worker.sh"

#### Begin of Magisk Boot Image Patcher ####

#bash "$WDIR/tools/patch.sh"

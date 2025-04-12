#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 SteamFork (https://github.com/SteamFork)

WORK_DIR="$(dirname $(realpath "${0}"))"
SOURCE_FILE="${WORK_DIR}/links.index"
APPS_PATH="${HOME}/Applications"
SCRIPT_PATH="${HOME}/bin"
SCRIPT_COMMAND="${SCRIPT_PATH}/steamfork-browser-open"

for DIR in "${APPS_PATH}" "${SCRIPT_PATH}"; do
    if [ ! -d "${DIR}" ]; then
        mkdir -p "${DIR}"
        echo "SETUP: Created directory ${DIR}."
    fi
done

if [ -e "${SOURCE_FILE}" ]; then
    rm "${SOURCE_FILE}"
    echo "SETUP: Removed existing source file ${SOURCE_FILE}."
fi

echo "SETUP: Fetching source data..."
curl -Lo "${SOURCE_FILE}" "https://github.com/SteamFork/SetupStreamingServices/raw/main/data/links.index"

echo "SETUP: Fetching browser script..."
curl -Lo "${SCRIPT_COMMAND}" "https://github.com/SteamFork/SetupStreamingServices/raw/main/bin/steamfork-browser-open"
chmod 0755 "${SCRIPT_COMMAND}"

BROWSER_CHOICE=$(zenity --list \
    --title="Browser Selection" \
    --text="Please select the browser you would like to use for all URLs:" \
    --radiolist \
    --column="Select" --column="Browser" \
    TRUE "Google Chrome and Microsoft Edge (Best Compatibility)" \
    FALSE "Brave Browser (Best Privacy)")

if [ $? -ne 0 ]; then
    echo "USER: Operation cancelled by the user."
    exit 0
fi

if [ "${BROWSER_CHOICE}" = "Brave Browser" ]; then
    echo "USER: Brave Browser selected. Overriding all browser selections."
    OVERRIDE_BROWSER="com.brave.Browser"
else
    echo "USER: Default browsers (Google Chrome and Microsoft Edge) selected."
    OVERRIDE_BROWSER=""
fi

declare -a allURLs=()
while read -r SITES; do
    SITE="${SITES%%|*}"
    echo "URLS: Found site ${SITE}."
    allURLs+=("FALSE" "${SITE}")
done < "${SOURCE_FILE}"

echo "URLS: All available sites: [${allURLs[@]}]"

URLS=$(zenity --title "Internet Media Links" \
    --list \
    --height=600 \
    --width=350 \
    --text="Please choose the links that you would like to add to Game Mode." \
    --column="Select" \
    --column="URL" \
    --checklist \
    "${allURLs[@]}")

if [ $? -ne 0 ]; then
    echo "USER: Operation cancelled by the user."
    exit 0
fi

declare arrSelected=()
IFS='|' read -r -a arrSelected <<< "${URLS}"
echo "URLS: Selected sites: ${arrSelected[@]}"

for ITEM in "${arrSelected[@]}"; do
    NEW_ITEM=$(grep "^${ITEM}|" "${SOURCE_FILE}")
    NAME="${NEW_ITEM%%|*}"
    NEW_ITEM="${NEW_ITEM#*|}"
    BROWSER="${NEW_ITEM##*|}"
    URL="${NEW_ITEM%%|*}"

    if [ -n "${OVERRIDE_BROWSER}" ]; then
        BROWSER="${OVERRIDE_BROWSER}"
    fi

    if [ ! -e "${APPS_PATH}/${NAME}.desktop" ]; then
        echo "INSTALL: Adding entry ${NAME} -> ${URL}."
        cat <<EOF >"${APPS_PATH}/${NAME}.desktop"
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=${SCRIPT_COMMAND} ${BROWSER} "${URL}"
EOF
        chmod 0755 "${APPS_PATH}/${NAME}.desktop"

        echo "INSTALL: Checking for ${BROWSER} Flatpak dependency..."
        flatpak info "${BROWSER}" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "INSTALL: Installing ${BROWSER} Flatpak..."
            sudo flatpak --assumeyes install "${BROWSER}"
            flatpak --user override --filesystem=/run/udev:ro "${BROWSER}"
        fi

        echo "INSTALL: Adding ${NAME} to Steam."
        steamos-add-to-steam "${APPS_PATH}/${NAME}.desktop"
        sleep 1
    else
        echo "INSTALL: Entry ${NAME} already exists. Skipping."
    fi
    unset NAME URL
done

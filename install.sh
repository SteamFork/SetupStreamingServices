#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 SteamFork (https://github.com/SteamFork)

WORK_DIR="$(dirname $(realpath "${0}"))"
SOURCE_FILE="${WORK_DIR}/links.index"
APPS_PATH="${HOME}/Applications"
SCRIPT_PATH="${HOME}/bin"
SCRIPT_COMMAND="${SCRIPT_PATH}/steamfork-browser-open"

for DIR in "${APPS_PATH}" "${SCRIPT_PATH}"
do
	if [ ! -d "${DIR}" ]
	then
		mkdir -p "${DIR}"
	fi
done

if [ ! -e "${SOURCE_FILE}" ]
then
	echo "Fetching source data..."
	curl -Lo "${SOURCE_FILE}" "https://github.com/SteamFork/SetupStreamingServices/raw/main/data/links.index"
fi

echo "Fetching browser script..."
curl -Lo ${SCRIPT_COMMAND} "https://github.com/SteamFork/SetupStreamingServices/raw/main/bin/steamfork-browser-open"
chmod 0755 ${SCRIPT_COMMAND}

declare -a allURLs=()
while read SITES
do
	SITE="${SITES%%|*}"
	echo "Found site: "${SITE}"..."
	allURLs+=("FALSE" "${SITE}")
done < ${SOURCE_FILE}

echo "[${allURLs[@]}]"

URLS=$( zenity --title "Internet Media Links" \
	--list \
	--height=600 \
	--width=350 \
	--text="Please choose the links that you would like to add to Game Mode." \
	--column="" \
	--column="URL" \
	--checklist \
	"${allURLs[@]}")

declare arrSelected=()
IFS='|' read -r -a arrSelected <<< ${URLS}
for ITEM in "${arrSelected[@]}"
do
	NEW_ITEM=$(grep "^${ITEM}|" ${SOURCE_FILE})
	NAME="${NEW_ITEM%%|*}"
	NEW_ITEM="${NEW_ITEM#*|}"
	BROWSER="${NEW_ITEM##*|}"
	URL="${NEW_ITEM%%|*}"
	if [ ! -e "${APPS_PATH}/${NAME}.desktop" ]
	then
		echo "Adding entry: ${NAME} -> ${URL}..."
		cat <<EOF >"${APPS_PATH}/${NAME}.desktop"
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=${SCRIPT_COMMAND} ${BROWSER} "${URL}"
EOF
	chmod 0755 "${APPS_PATH}/${NAME}.desktop"

	echo "Install ${BROWSER} Flatpak (dependency)..."
	BROWSER_INSTALLED=$(flatpak info ${BROWSER} >/dev/null 2>&1)
	if (( $? > 0 ))
	then
		sudo flatpak --assumeyes install ${BROWSER}
		flatpak --user override --filesystem=/run/udev:ro ${BROWSER}
	fi

	echo "Adding: ${NAME} to Steam..."
	steamos-add-to-steam "${APPS_PATH}/${NAME}.desktop"
	sleep 1
        else
                echo "Not adding entry: ${NAME}, as it already exists..."
        fi
	unset NAME URL
done

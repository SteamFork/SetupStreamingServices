#!/bin/bash

WORK_DIR="$(dirname $(realpath "${0}"))"
SOURCE_FILE="${WORK_DIR}/.links.index"
APPS_PATH="${HOME}/Applications"

if [ ! -e "${SOURCE_FILE}" ]
then
  curl -Lo "${SOURCE_FILE}" "https://github.com/SteamFork/SetupStreamingServices/raw/main/links.index"
fi

if [ ! -d "${APPS_PATH}" ]
then
	mkdir -p "${APPS_PATH}"
fi

declare -a allURLs=()
while read SITES
do
	SITE="${SITES%|*}"
	echo "Found site: "${SITE}"..."
	allURLs+=("${SITE}")
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
	NAME="${NEW_ITEM%|*}"
	URL="${NEW_ITEM#*|}"
	echo "Adding entry: ${NAME} -> ${URL}..."
	cat <<EOF >"${APPS_PATH}/${NAME}.desktop"
[Desktop Entry]
Icon=
Name=${NAME}
Type=Application
Exec=/usr/bin/steamfork-browser-open "${URL}"
EOF
	echo "Adding: ${NAME} to Steam..."
	steamos-add-to-steam "${APPS_PATH}/${NAME}.desktop"
	sleep 1
	unset NAME URL
done

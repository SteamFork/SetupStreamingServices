## Setup Streaming Services
This script will provide a UI to select any URLs found in the `data/links.index` source file, and will create desktop icons and add them to GameScope.  It is compatible with all devices running SteamOS.

### Supported URLs
The list below is based on the index found in the source tree and may not contain the full list.  Review [data/links.index](/data/links.index) for the most up-to-date data.

* [Amazon Luna](https://luna.amazon.com)
* [Amazon Prime Video](https://www.amazon.com/video)
* [Antstream](https://live.antstream.com)
* [Apple TV](https://tv.apple.com)
* [Crave](https://www.crave.ca)
* [Crunchyroll](https://www.crunchyroll.com)
* [Discord](https://discord.com/app)
* [Disney+](https://www.disneyplus.com)
* [Dropout](https://www.dropout.tv/browse)
* [Emby Theater](https://emby.media)
* [HBO Max](https://www.max.com)
* [Home Assistant](https://demo.home-assistant.io)
* [Hulu](https://www.hulu.com)
* [Nebula](https://nebula.tv)
* [Netflix](https://www.netflix.com)
* [Paramount+](https://www.paramountplus.com)
* [Peacock TV](https://www.peacocktv.com)
* [Plex](https://app.plex.tv)
* [Pocket Casts](https://play.pocketcasts.com)
* [Spotify](https://open.spotify.com)
* [TikTok](https://www.tiktok.com)
* [Twitch](https://www.twitch.tv)
* [Twitter](https://twitter.com)
* [Vimeo](https://vimeo.com)
* [Xbox Cloud Gaming](https://www.xbox.com/play)
* [YouTube Music](https://music.youtube.com)
* [YouTube TV](https://tv.youtube.com)
* [YouTube](https://www.youtube.com)
* [webRcade](https://play.webrcade.com)

### Installation
Before running this script, be sure to switch to desktop mode and install Google Chrome from the discovery software center.  Once completed, open `konsole`, and paste the installation script to get started.

```
curl -L https://github.com/SteamFork/SetupStreamingServices/raw/main/install.sh | bash
```

Return to Gamescope, and use the [SteamGridDB](https://github.com/SteamGridDB/decky-steamgriddb) Decky plugin to add images to the new streaming services launchers.

### Uninstalling
1. Delete the launchers from Steam.
2. Remove the related .desktop files from ~/Applications.
3. Delete steamfork-browser-open from ~/bin.

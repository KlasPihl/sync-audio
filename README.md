# sync-USBmusic

Sync files on USB drive from configuration file.

## Usage
When USB stick is inserted mp3 files is automaticly synced/updated from configuration file.

Ex the newest podcasts.

Old mini stereo receiver on the "conservatory" that only can play mp3's, no streaming.

## Files
* sync-config.json
* sync-audio.ps1
* autorun.cmd
* autorun.ini

## Configuration file

```json
[
  {
    "Title": "podcast",
    "Source": "\\\\pihl-fs\\Pihl\\Music\\Pod",
    "Age": 14
  },
  {
    "Title": "Tophit2022",
    "Source": "\\\\pihl-fs\\Pihl\\Music\\_TopHit 2022"
  },
  {
    "Title": "Tophit2021",
    "Source": "\\\\pihl-fs\\Pihl\\Music\\_TopHit 2021",
    "Age": 180
  }
]
```
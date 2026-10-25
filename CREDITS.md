# Credits

## Optional audio

Audio is optional in the gray-box build. To add a sound, place an `.ogg` file
in `assets/audio/` with one of these ids:

- `hoe`
- `water`
- `seed`
- `harvest`
- `footstep`
- `music`

The runtime calls `AudioService.play_sound(&"id")`. If the file is absent, the
game remains silent and continues normally.

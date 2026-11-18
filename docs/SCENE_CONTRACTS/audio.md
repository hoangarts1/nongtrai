# Audio presentation contract — Phase7.2 (D103)

## Phase7.2a bus routing

No existing scene, node path, autoload, InputMap or save change. Godot loads default_bus_layout.tres: exactly Master, Music, SFX, Ambience, UI; all children send directly to Master. Initial gains are unity; no bus effects. LifeAudioBusRouter is transient core RefCounted, not a scene/autoload/state owner. API: is_layout_ready()->bool (static), apply_accepted()->bool. It validates every required bus/send before modifying gains, reads accepted Settings and sets Music=music_volume, Ambience/UI=effects_volume, SFX=1. Master is not changed. Invalid layout returnsfalse without partial mutation; the router never silently rebuilds another layout.

Existing AudioService remains the same Main-owned Node and public play_sound/get_sound_path API. It owns one RefCounted router, no extra child nodes. _ready applies accepted bus gains then connects its existing single preferences_changed listener. Accepted changes update bus gains and active SFX players; new SFX players use busSFX plus their original effects_volume volume_linear. SFX bus unity avoids double attenuation. If required layout is missing, existing playback falls back toMaster and warns on setup; no file/owner repair. Missing clip behavior and finished-player cleanup remain.

Phase7.2b will add standalone assets/profile; Phase7.2c will add runtime loop selection only after their own gates. No loop or music is enabled in7.2a. Native API/geometry here means pinned engine reflection and actual bus/player properties, not a human listening certificate. Test fixtures snapshot/restore bus layout and isolated Settings bytes; no editor wiring or manual bus creation is required.

# ShakeCheer user audio pipeline

`scripts/install_user_audio.py` replaces the 16 manually selected sounds before XcodeGen in both GitHub Actions and Codemagic. The script downloads the corresponding Freesound/BigSoundBank recordings, applies the approved trim windows, normalizes them, and writes the final MP3 files into `Resources/`.

This exists specifically to prevent stale placeholder/previous audio in the repository from being compiled into TestFlight builds.

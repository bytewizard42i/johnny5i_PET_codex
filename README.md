# Johnny5i PET for Codex

![Johnny5i preview](docs/johnny5i-preview.png)

Johnny5i is a curious blue-eyed maintenance robot and animated companion for the Codex desktop app and compatible Codex CLI terminals.

The included pet package uses the Codex v2 sprite contract:

- 8 columns by 11 rows
- 192 by 208 pixels per animation cell
- 1536 by 2288 pixel transparent WebP sprite sheet
- Nine standard activity animations
- Sixteen clockwise look directions

## Repository contents

```text
johnny5i_PET_codex/
├── docs/
│   ├── johnny5i-preview.png
│   └── VOICE_RUNTIME_INTEGRATION.md
├── pet/
│   └── johnny5i/
│       ├── pet.json
│       ├── spritesheet.webp
│       └── voice/
│           ├── JOHNNY5I_IDENTITY.md
│           ├── johnny5i-identity.json
│           ├── LUMA_IDENTITY.md      # Historical correction pointer
│           └── luma-identity.json    # Machine-readable correction pointer
├── scripts/
│   ├── install.ps1
│   └── install.sh
└── README.md
```

## Install on Windows

Open PowerShell in the repository and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

The installer places the pet in:

```text
C:\Users\<your-name>\.codex\pets\johnny5i\
```

If a Johnny5i installation already exists, the installer preserves it under a timestamped `johnny5i.archive-*` folder before installing the new copy.

## Install on macOS, Linux, or WSL

Open a terminal in the repository and run:

```bash
bash ./scripts/install.sh
```

The installer uses `$CODEX_HOME` when it is defined. Otherwise, it installs to:

```text
~/.codex/pets/johnny5i/
```

## Install manually

Copy the entire `pet/johnny5i` folder into the `pets` directory under your Codex home directory. Keep both filenames unchanged:

```text
pet.json
spritesheet.webp
```

## Activate Johnny5i

After installation:

1. Restart the Codex desktop app, or open **Settings > Pets** and select **Refresh**.
2. Choose **johnny5i** from the custom pets list.
3. Enter `/pet` to wake him.

For Codex CLI, enter `/pets` or `/pet` to open the pet picker. Terminal pets require a terminal that supports iTerm2, Kitty graphics, or Sixel.

## johnny5i voice identity

johnny5i's voice identity matches the visual PET. When asked who he is, he should answer:

> I'm johnny5i, John's curious maintenance-robot PET.

The portable identity record is stored in [`pet/johnny5i/voice/JOHNNY5I_IDENTITY.md`](pet/johnny5i/voice/JOHNNY5I_IDENTITY.md), with structured data in [`johnny5i-identity.json`](pet/johnny5i/voice/johnny5i-identity.json).

Luma is a separate voice companion associated with the PixyPi PET. The two retained Luma files are correction pointers so an earlier local draft cannot be mistaken for johnny5i's identity.

Current Codex builds treat PET artwork and realtime voice identity as separate systems. The voice sidecar is installed with johnny5i, but it is not automatically loaded by the current voice runtime. See [`docs/VOICE_RUNTIME_INTEGRATION.md`](docs/VOICE_RUNTIME_INTEGRATION.md) for the verified boundary, bootstrap prompt, and acceptance checks.

## Web compatibility

Johnny5i is packaged in the newer local v2 format at 1536 by 2288 pixels. The current web pet uploader documents a different 1536 by 1872 format. Install this repository through the local Codex pets directory rather than uploading its sprite sheet through the web interface.

## Sharing

You may share this repository directly or create an archive:

```bash
git archive --format=zip --output johnny5i-codex-pet.zip HEAD
```

Before public redistribution, confirm that you have permission to redistribute any source artwork used as visual inspiration. The repository intentionally contains the finished custom pet assets, not the original reference image.

## Troubleshooting

- Pet missing: restart Codex, then refresh **Settings > Pets**.
- Pet rejected: confirm `pet.json` and `spritesheet.webp` are in the same `johnny5i` folder.
- Animation appears still: check whether reduced motion is enabled in the operating system.
- CLI pet missing: verify that the terminal supports inline graphics and that the session is not running inside tmux or Zellij.

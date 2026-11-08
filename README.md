# Teyvat Tracker (Genshin Impact to-do app for sideloading)

A small SwiftUI iOS app (iOS 16+) that stores everything locally on your phone.

## Features
- **Today** – server day & countdown to the 4:00 reset, a compact wish-savings card, which of *your* characters can farm talent books today, and daily / weekly / one-off checklists that reset themselves. Tap Reorder to drag domains and tasks into your preferred order.
- **Roster** – all 122 characters through 7.x with icons, owned toggle, typed-in level, constellation, friendship, talent levels, a "currently building" flag, notes and KQM Quick Guide / Infographic links (open in an in-app popup). Filter by owned / element, search, and add new characters yourself.
- **Materials** – "have / need / X more to go" trackers with item icons and +/- buttons, grouped by character (tap a character to collapse/expand, reorder characters from the menu). Double-tap an item's name to mark it collected. **Plan a character** fills in the exact shopping list from their current level to any ascension target (Lv. 20–90) and for 0–3 talents from any starting level to 10 — edit the plan later from the character's menu and the needs update while your 'have' counts are kept: gems, boss drop, local specialty, common drops, books, weekly boss and crowns.
- **Weapons** – in Roster, switch to Weapons to track any of the 253 weapons (level, refinement, who uses it) and plan its ascension: domain materials, elite drops, common drops, Mystic Enhancement Ore and Mora. Planned weapons show on Materials and on Today when their domain is open.
- **Domains** – pick any weekday to see every talent-book and weapon-material domain that's open, and which characters use each book.
- **More** – theme colour & light/dark mode, server selection, wish savings & pity calculator, edit checklist tasks, add custom talent books (for new regions), and JSON backup/restore.

## Building the .ipa (no Mac needed)
iOS apps must be compiled with Xcode on macOS, so this repo uses a free GitHub Actions macOS runner:

1. Create a new GitHub repository and upload **everything in this folder**, including the hidden `.github` folder.
2. Open the repo's **Actions** tab. The "Build IPA" workflow runs on every push (or press *Run workflow*).
3. When it finishes (~3–5 min):
   - On the `main` branch, a **Release** named "Teyvat Tracker build N" is created with `GenshinTracker.ipa` attached – open it from Safari on your iPhone and share it to Feather.
   - The IPA is also attached to the workflow run as an artifact (downloads as a .zip containing the .ipa).
4. In Feather, import the IPA, sign it with your certificate and install.

To build locally on a Mac instead: `./build.sh` → `build/GenshinTracker.ipa`.

## Updating with Feather (one tap)
Add this source in Feather → **Sources → +**:

```
https://github.com/gleamhairfree/genshin-up/releases/latest/download/source.json
```

Every push to `main` builds a new version (1.0.N) and updates the source, so Feather shows it as an update. The app's **More → Updates** section can also check for new versions.

## Notes
- Material data and item icons come from paimon.moe's public data. Character data comes from Enka.Network's public game data; icons load from enka.network the first time and are cached on the phone.
- The IPA is unsigned (ad-hoc), as Feather expects.
- Talent book assignments for some newer characters are left blank – set them on the character's page. New regions' books can be added under More → Custom talent books.
- Back up via More → Copy backup before re-signing with a different certificate, as that can wipe app data.

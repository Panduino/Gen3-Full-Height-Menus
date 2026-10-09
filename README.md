# Gen 3 Full-Height Menus

Standalone FireRed / LeafGreen menu scaling for Gen1Recomp.

Scales the visible **240×160** Gen 3 menu viewport proportionally to fit the display height. On a 1920×1080 monitor, menus display at **1620×1080**, centered with 150-pixel side borders.

## Covered screens
- In-game menus handled by the Gen 3 menu stack, including Pokémon party, summary, PC storage, Bag, Pokédex, Trainer Card, Options and Save.
- Boot/title and Continue/New Game/save-selection screens.
- FireRed/LeafGreen's **Previously on Your Quest** flashback.
- Other boot screens that use the same Gen 3 drawing path.

Does **not** change dialogue windows in normal gameplay, overworld rendering, or battle rendering. No assets or code from the G9 battle sprite mod are required.

## Installation
Install this branch as its own mod. Do not install the same scaling feature from an older copy of the G9 Gen 3 Battle Sprites mod at the same time.

## Notes
The scaling is a render-only hook; menu input and navigation remain unchanged. In-game validation is still needed, especially for screens supplied by other mods.

# EllesmereUI KR Patch

Standalone overlay addon for the EllesmereUI suite.

## Purpose
- Keep Korean localization outside the upstream EllesmereUI addon folders.
- Force the suite-wide UI/game font choice to `Fonts\\2002.ttf` for `koKR`.
- Re-apply localization to the settings UI and `Unlock Mode` after pages are built.
- Localize EUI chat messages, popup text, dropdown menus, and the EllesmereUI minimap tooltip from the overlay layer.

## Files
- `Localization_koKR.lua`: Korean translation tables and recursive frame text localization.
- `Core.lua`: EllesmereUI hook layer, tooltip translation, font overrides, and post-build relocalization.

## Future changes
- Add new Korean strings in `Localization_koKR.lua`.
- Add new runtime hooks or frame-specific fixes in `Core.lua`.
- Do not copy upstream EllesmereUI files into this addon.

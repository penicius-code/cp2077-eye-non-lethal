# Changelog

Versions up to 1.4.0 were built on game version 2.31. From 1.5.0 the mod is for 2.5. "Not run in game" means compile-checked only.

## 1.6.0 - 2026-11-23
### Changed
- With the mode on, a limb cut takes the limb and leaves the target alive; a head cut kills; torso hits cause no gore and no kill.
- A finishing hit on a body that another damage mod holds invulnerable releases that hold first, so the cut is not refused.

Not run in game.

## 1.5.0 - 2026-11-17
### Changed
- Port to game version 2.5: the key input API changed, the press is now checked in the handler.

Not run in game.

## 1.4.0 - 2026-11-05
### Changed
- Explosives and lethal grenades kill with the mode on. Flash, smoke, EMP, recon and sonic grenades are not lethal.
- For 15 seconds after a lethal blast, damage-over-time ticks on that enemy count as lethal too.

Not run in game.

## 1.3.0 - 2026-11-02
### Added
- One more optional eye model in the tag list.

Confirmed in game.

## 1.2.0 - 2026-11-01
### Fixed
- The non-lethal flag is set before the `PreProcess` damage stage, so another damage mod sees it and no longer puts the knocked-out body into its own dying state.
### Changed
- The finishing rule applies to every human target, whatever eyes are worn.

Confirmed in game.

## 1.1.1 - 2026-11-01
### Changed
- Any melee swing at a downed human finishes, not only blades.

## 1.1.0 - 2026-11-01
### Changed
- The tag list covers every Kiroshi model from Epic up. No code change.

## 1.0.3 - 2026-11-01
### Fixed
- With the key off, hits are lethal even with eyes that add their own non-lethal flag. Weapons with a non-lethal weapon mod keep theirs.

## 1.0.2 - 2026-10-31
### Fixed
- A blade swing at a body already on the ground now finishes it with eyes that add their own non-lethal flag.

Confirmed in game.

## 1.0.0 - 2026-10-31
- First version: a key toggles non-lethal mode for two eye models; the state is kept in the save.

Confirmed in game.

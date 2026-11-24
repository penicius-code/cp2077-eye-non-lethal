# Cyberslop Eye Non-Lethal

A key that switches your Kiroshi optics to non-lethal mode, for Cyberpunk 2077: hits on human enemies knock out instead of kill. Single-player only.
Version 1.6.0 | For game version 2.5 | Status: versions up to 1.3.0 confirmed in game on 2.31; 1.4.0 to 1.6.0 compile on 2.5 and are not yet play-tested

**Download:** [latest release](https://github.com/penicius-code/cp2077-eye-non-lethal/releases/latest) (zip; install steps below)

> This is an unofficial fan work and is not approved/endorsed by CD PROJEKT RED. No game files are included.

## The problem

Non-lethal play in the base game depends on the weapon: you need a weapon mod or a blunt weapon, and you cannot switch during a fight. An eye mod that makes every hit non-lethal goes too far the other way: it also spares bosses, machines and bodies you want to finish, and it stops dismemberment entirely.

## What I built

One key that toggles a non-lethal mode tied to the eye cyberware you wear. It changes: whether the player's hits on ordinary human enemies carry the game's own non-lethal flag, and how downed bodies, explosives and limb cuts are treated while that flag is on. 449 lines of redscript and a TweakXL file that tags 60 Kiroshi eye items.

## How it works

- The script wraps the game's damage functions (`@wrapMethod` only). While the mode is on and the equipped eyes carry the mod's tag, every hit of the player on a human who is not a boss or an elite police unit gets the vanilla non-lethal flag before the damage is processed. An empty health bar then knocks out.
- The flag is added in the `PreProcess` stage, so other mods that read it early see it.
- A melee swing at a body that is already down finishes it, with the mode on or off. Guns and damage-over-time ticks keep the flag there, so the rest of a burst does not kill the body just knocked out.
- Explosives and lethal grenades kill with the mode on. For 15 seconds after such a blast, damage-over-time ticks on that enemy count as lethal too.
- Limb cuts work with the mode on and leave the target alive; a head cut kills.
- The on/off state is a quest fact, so it is kept in the save.
- The TweakXL file adds the tag and one tooltip line to the eye items: basic Kiroshi optics at every tier, every other Kiroshi model from Epic up, and the items of two optional eye mods.

```text
package/r6/
  scripts/zz_CyberslopEyeNonLethal/CyberslopEyeNonLethal.reds
  tweaks/zz_CyberslopEyeNonLethal/CyberslopEyeNonLethal.yaml
```

The folder name starts with `zz_` on purpose: redscript loads folders in alphabetical order, and these wraps must load after the mods they cooperate with.

## Requirements

| Requirement | Version | Link |
|---|---|---|
| Cyberpunk 2077 | 2.5 | |
| redscript | a build for 2.5 | [Nexus Mods, mod 1511](https://www.nexusmods.com/cyberpunk2077/mods/1511) |
| TweakXL | a build for 2.5 | [Nexus Mods, mod 4197](https://www.nexusmods.com/cyberpunk2077/mods/4197) |
| Codeware | a build for 2.5 | [Nexus Mods, mod 7780](https://www.nexusmods.com/cyberpunk2077/mods/7780) |

Codeware provides the key input. Requirements are not bundled. Exact framework versions used for the 2.5 build were not written down.

## Install

1. Install the requirements above.
2. Download the zip from the [latest release](https://github.com/penicius-code/cp2077-eye-non-lethal/releases/latest) (the same files as `package/` in this repository) and extract it into the game folder.
3. Start the game, equip Kiroshi optics that qualify (their tooltip shows the line "Non-lethal mode ...") and press the key left of Z. A message "Non-lethal: ON" appears.

## Uninstall / roll back

1. Close the game.
2. Delete `r6\scripts\zz_CyberslopEyeNonLethal` and `r6\tweaks\zz_CyberslopEyeNonLethal`.
3. Saves keep working. The on/off state remains in the save as an unused quest fact.

## Configuration

There is no settings page. The key is fixed to `IK_IntlBackslash`, the key left of Z on ISO keyboards.

## Status

| Version | Game | Result |
|---|---|---|
| 1.0.0, 1.0.2 | 2.31 | Confirmed in game (toggle; finishing a downed body), 2026-10-31. |
| 1.2.0 | 2.31 | Confirmed in game, 2026-11-01. |
| 1.3.0 | 2.31 | Confirmed in game (added eye model). |
| 1.4.0 | 2.31 | Not run in game. |
| 1.5.0 | 2.5 | Port of the key handling to 2.5. Compiles. Not run in game. |
| 1.6.0 | 2.5 | Compiles (0 errors). Not run in game; its test list is still open. |

All 6 wrap targets in the game's own classes match the 2.5 game scripts. A seventh wrap targets a method of an optional limb-damage mod and is compiled only when that mod is installed.

## Compatibility

| Item | Status | Notes |
|---|---|---|
| Keyboards without a key left of Z (ANSI layout) | not usable | The key is fixed in the script. |
| Ped Damage Overhaul 2077 | handled | The flag is set early enough for it to see; a finishing hit releases the hold it places on a dying body. |
| KIROSHI Non-Lethal eyes, Kiroshi Optics Echo (other authors' mods) | optional | Their items are in the tag list. With the key off, hits are lethal even with those eyes. Weapons with a non-lethal weapon mod keep their flag. |
| The game without those two mods | not checked | The tweak file refers to their item records; what TweakXL reports for missing records was not checked. |
| Bosses, elite police units, machines | never affected | |

## Known issues

- No settings page and no way to change the key without editing the script.
- Versions 1.4.0 to 1.6.0 have not been played.

## Engineering notes

**Symptom.** With one eye mod equipped, a blade swing at a knocked-out body did nothing: no finishing blow, no dismemberment. The mod's own rule ("a blade on a downed body finishes") did not seem to run.

**Diagnosis.** A hit logger showed the non-lethal flag on those hits with a source name that was not this mod's. That eye mod carries a vanilla effect package whose native code puts the non-lethal flag on every hit of the player in the `PreProcess` stage, before this script runs, and on everything: mechs, bosses, blasts and bleed ticks. The earlier version only declined to add its own flag, so the other flag stayed.

**Fix.** For a melee swing at a human already on the ground, the flag is removed whoever added it, so the game's own finishing and gore path runs. With the key off, that eye mod's flag is removed from hits on humans, so "off" means lethal with those eyes too. A weapon with a non-lethal weapon mod uses the same effect class and is left alone by checking the source name.

**Later, the same idea in the other direction.** Another damage mod read the flag in `PreProcess` while this mod added it one stage later. Version 1.2.0 moved the flag into a `PreProcess` wrap.

**Rollback.** Each version was installed with a backup of the previous files. For a user: delete two folders.

## Changelog

See [CHANGELOG.md](CHANGELOG.md). Latest: 1.6.0 (2026-11-23): limb cuts with the mode on leave the target alive.

## Credits and licence

Runs on redscript, TweakXL and Codeware, which are not included here.

MIT, see [LICENSE](LICENSE). The licence covers my code only. Game names and trademarks belong to their owners.

Built with AI assistance (Claude); designed, tested and maintained by me.

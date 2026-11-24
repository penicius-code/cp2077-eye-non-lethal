// Cyberslop Eye Non-Lethal 1.6.0 (2026-11-23), for game 2.5
// 1.6.0: gore with the mode on (design goal: "limbs should be taken off with non lethal on, keeping the target alive, same
// behaviour as when non lethal is disabled; only head gore should kill"). Three gates refused every cut while the
// hit carried Nonlethal: vanilla CanDieCondition (Nonlethal + defeat mechanic, so ProcessWoundsAndDismemberment
// returned at once), this file's DismembermentConditions wrap, and Relentless (CLS_LimbBlockReason and
// CLS_PrepareFirstLimbDamage skip Nonlethal hits). Now, for a hit the mode spares (key on, tagged eyes, human, no
// boss / MaxTac; not a blast, effect or damage-over-time tick) whose Nonlethal entry is the mode's or the eyes' own:
// - on a limb (arm, hand, leg) or the head, that entry is taken off while ProcessWoundsAndDismemberment runs and put
//   back right after, so vanilla gore and Relentless see the hit the same way as with the key off;
// - after a limb cut, NPCPuppet.Kill is skipped and m_isAlive / reaction / intensity go back to their values from
//   before the call (Downed Limb Cuts' method), so the target lives: standing if Relentless capped the damage,
//   knocked out if the hit emptied the health bar;
// - a head cut kills as with the key off. Torso hits keep the flag: no gore, no kill.
// - Relentless's first-limb damage cap (CLS_PrepareFirstLimbDamage, only when that module is installed) also sees
//   the hit without the entry, so a limb cut leaves the target standing as with the key off.
// The damage pipeline itself still sees Nonlethal: a hit that empties the bar still knocks out.
// - Body perk Obliterate (shotgun / LMG / HMG execute) takes the head too, so it keeps its Kill.
// Key on or off: a finishing hit (Finishes) on a body PDO's dying loop holds Invulnerable drops that hold before the
// gore runs. The Invulnerable effect only sets the IsInvulnerable stat, and vanilla CanDieCondition refuses all gore
// on it (2026-11-23, key off: monowire cut on a PDO body refused).
// 1.5.0: game 2.5 port. 2.5 declares InputTarget.Key natively as (key, opt threshold: Float); the press / release
// filter argument is gone, so OnKey checks the action itself. No other change.
// 1.4.0: explosives and lethal grenades kill with the mode on (realism; a launcher round or a frag doesn't knock
// out). Lethal = an attack whose source is a grenade (BaseGrenade.SpawnAttack sets the grenade as source for its blast,
// cutting beams, Misoru tornado blades and their bleed / burn / poison add-ons), unless the grenade is tagged Flash,
// Smoke, EMP, Recon or Sonic; plus every other Explosion attack (Projectile Launch System, grenade launchers, barrels,
// mines). Such a hit gets no flag from this mod and the eyes' own entry is removed (Pax kept). For 15 s after a lethal
// blast hit, damage-over-time ticks on that NPC count as lethal too (vanilla max: bleed 10 s, burn 8 s, poison 5 s).
// Flags an attack record carries itself (PreAttack) stay. Before 1.4.0 every blast only knocked out, so
// PLSObliterate (CanDieCondition) and vanilla gore never ran on humans while the mode was on.
// 1.2.0: the mode's flag is added before PreProcess, where PDO reads it (ProcessLocalizedDamage), so PDO skips the
// knockout and the body stays vanilla Unconscious instead of entering PDO's dying state, whose loop re-applies
// BaseStatusEffect.Invulnerable every tick and zeroed every later swing. A finishing melee swing on a body
// PDO already holds invulnerable (no god mode on it) gets IgnoreImmortalityModes, so the invulnerability check skips it.
// The finishing rule now applies to every human target, tagged eyes or not.
// 1.1.1: any melee swing on a downed human finishes, not only blades (Toggle.IsMeleeSwing replaces IsBlade): Gorilla
// Arms, fists, blunt weapons and blades alike. A swing at a body on the ground is deliberate; guns, thrown weapons and
// bleed or burn ticks still keep the flag there, or the rest of a burst or a bleed would kill the body just knocked out.
// 1.1.0: no code change; the tweak now tags every Kiroshi model from Epic up (Basic and 12503 at all tiers).
// 1.0.3: with the key off, the eyes' own flag (source name AddHitFlagToAttackEffector) is removed
// from V's hits on humans, so OFF means lethal with the 12503 eyes too. A weapon with a Pax mod (Items.GenericMod1_*,
// same effector class and source name) keeps it. Bleed and burn ticks (source PreAttack), quickhacks, fists and the
// non-lethal grenade carry their own flag under other names and are not touched.
// Non-lethal mode for V's Kiroshi eyes. The key left of Z (IK_IntlBackslash, ISO keyboards) switches it. While it is
// on and the eyes carry the CyberslopNonLethalEyes tag (r6\tweaks\zz_CyberslopEyeNonLethal), every hit of V's on a
// human carries the vanilla Nonlethal flag: an empty health bar knocks out and the hit reaction can't kill
// (NPCPuppet.OnPotentialDeath, HitReactionComponent.CanDieCondition).
// 1.0.2: the KIROSHI Non-Lethal eyes (Nexus 12503) carry the vanilla Target Analysis package
// (Items.KiroshiOpticsFragment1_inline1), whose native AddHitFlagToAttackEffector puts Nonlethal on every hit of
// V's in the PreProcess stage, before this file runs: mechs, bosses, blasts and bleed ticks included. 1.0.1 only
// declined to add the flag, so with those eyes a blade on a downed body stayed Nonlethal and no head came off.
// A blade swing (Toggle.IsBlade) on a human already on the ground (Toggle.IsDown) now has the flag removed, key on
// or off, so the vanilla gore path runs: CanDieCondition passes and DismembermentConditions takes IsDefeated, which
// is true for Unconscious too (BaseStatusEffect.Unconscious has the Defeated type). Guns, thrown weapons, blunt
// melee and bleed or burn ticks keep the flag on a living downed body, or the rest of a burst or a bleed would kill
// the body just knocked out. Bosses and MaxTac are never touched. Flags added later in the DamageSystem.Process
// chain (Gorilla Yeet, Push/Pull impacts, Road Crossing) are not affected: this wrap runs first.
// The state is a quest fact, so it stays in the save. Key input comes from Codeware because CET's binder has no name
// for this key. Remove: delete this folder and the tweak folder. Saves do not depend on it.
module CyberslopEyeNonLethal

// 1.4.0: sim time until which damage-over-time ticks on this NPC count as part of a lethal blast
@addField(NPCPuppet)
public let m_cyberslopBlastLethalUntil: Float;

// 1.6.0: set while ProcessWoundsAndDismemberment runs for a spared limb hit; Kill() is skipped and noted
@addField(NPCPuppet)
public let m_cenlSpareKill: Bool;

@addField(NPCPuppet)
public let m_cenlKillSkipped: Bool;

public class Toggle extends ScriptableSystem {
  private let m_keyCallback: ref<CallbackSystemHandler>;

  private func OnAttach() -> Void {
    this.m_keyCallback = GameInstance.GetCallbackSystem().RegisterCallback(n"Input/Key", this, n"OnKey", true)
      .AddTarget(InputTarget.Key(EInputKey.IK_IntlBackslash));
  }

  private func OnDetach() -> Void {
    if IsDefined(this.m_keyCallback) {
      this.m_keyCallback.Unregister();
    };
  }

  private cb func OnKey(event: ref<KeyInputEvent>) -> Void {
    // 2.5 port: the target no longer filters by action
    if NotEquals(event.GetAction(), EInputAction.IACT_Press) {
      return;
    };
    let game: GameInstance = GetGameInstance();
    let player: ref<PlayerPuppet> = GetPlayer(game);
    if !IsDefined(player) || GameInstance.GetBlackboardSystem(game).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu) {
      return;
    };
    if !Toggle.HasEyes(player) {
      Toggle.Show(game, "Non-lethal: these eyes can't do it");
      return;
    };
    let on: Bool = !Toggle.IsOn(game);
    GameInstance.GetQuestsSystem(game).SetFact(n"cyberslop_eye_nonlethal", on ? 1 : 0);
    Toggle.Show(game, on ? "Non-lethal: ON" : "Non-lethal: OFF");
    FTLog(s"[CyberslopEyeNonLethal] \(on)");
  }

  public static func IsOn(game: GameInstance) -> Bool {
    return GameInstance.GetQuestsSystem(game).GetFact(n"cyberslop_eye_nonlethal") == 1;
  }

  public static func HasEyes(player: ref<PlayerPuppet>) -> Bool {
    let data: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(player);
    if !IsDefined(data) {
      return false;
    };
    let slots: Int32 = data.GetNumberOfSlots(gamedataEquipmentArea.EyesCW);
    let i: Int32 = 0;
    while i < slots {
      let item: ItemID = data.GetItemInEquipSlot(gamedataEquipmentArea.EyesCW, i);
      if ItemID.IsValid(item) {
        let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item));
        if IsDefined(record) && record.TagsContains(n"CyberslopNonLethalEyes") {
          return true;
        };
      };
      i += 1;
    };
    return false;
  }

  // A human who isn't a boss or MaxTac, hit by V: the finishing rule applies to these whatever the eyes (1.2.0)
  public static func IsHumanTarget(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Bool {
    if !IsDefined(player) || !IsDefined(npc) {
      return false;
    };
    return Equals(npc.GetNPCType(), gamedataNPCType.Human) && !npc.IsBoss() && NotEquals(npc.GetNPCRarity(), gamedataNPCRarity.MaxTac);
  }

  // A human who isn't a boss or MaxTac, hit by V wearing the tagged eyes: the targets the mode itself touches.
  public static func Covers(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Bool {
    return Toggle.IsHumanTarget(player, npc) && Toggle.HasEyes(player);
  }

  // 1.2.0: a downed body PDO's dying loop keeps invulnerable (BaseStatusEffect.Invulnerable re-applied every tick).
  // Vanilla never leaves that effect on a downed NPC (a carried body has it, and V can't swing at one), so with no
  // god mode on the NPC a finishing swing may ignore it. Quest characters under Immortal or Invulnerable god mode stay.
  public static func HeldInvulnerable(npc: ref<NPCPuppet>) -> Bool {
    if !StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.Invulnerable") {
      return false;
    };
    let god: ref<GodModeSystem> = GameInstance.GetGodModeSystem(npc.GetGame());
    return !god.HasGodMode(npc.GetEntityID(), gameGodModeType.Invulnerable) && !god.HasGodMode(npc.GetEntityID(), gameGodModeType.Immortal);
  }

  public static func Spares(player: ref<PlayerPuppet>, npc: ref<NPCPuppet>) -> Bool {
    return IsDefined(player) && Toggle.IsOn(player.GetGame()) && Toggle.Covers(player, npc);
  }

  // IsAboutToDieOrDefeated covers the frames between an empty health bar and its status effect. IsDefeated is true
  // for Defeated, DefeatedWithRecover and Unconscious (all of the Defeated type); PDO's dying state is Defeated.
  // A lost leg means Limb Survival's crawl.
  public static func IsDown(npc: ref<NPCPuppet>) -> Bool {
    return npc.IsAboutToDieOrDefeated() || ScriptedPuppet.IsDefeated(npc) || ScriptedPuppet.IsUnconscious(npc) || npc.IsRagdolling()
      || StatusEffectSystem.ObjectHasStatusEffectOfType(npc, gamedataStatusEffectType.Knockdown)
      || StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.DismemberedLegLeft")
      || StatusEffectSystem.ObjectHasStatusEffect(npc, t"BaseStatusEffect.DismemberedLegRight");
  }

  // 1.1.1: a light or strong melee swing with anything: blades, blunt weapons, Gorilla Arms, fists
  public static func IsMeleeSwing(attackData: ref<AttackData>) -> Bool {
    return AttackData.IsLightMelee(attackData.GetAttackType()) || AttackData.IsStrongMelee(attackData.GetAttackType());
  }

  // A corpse is no one to spare, and Nonlethal stops all gore on it (CanDieCondition), whatever the weapon.
  public static func Finishes(npc: ref<NPCPuppet>, attackData: ref<AttackData>) -> Bool {
    return !ScriptedPuppet.IsAlive(npc) || Toggle.IsDown(npc) && Toggle.IsMeleeSwing(attackData);
  }

  // Every Nonlethal entry goes, whatever put it there (the eyes' effector, a weapon record, this mod).
  public static func StripNonlethal(attackData: ref<AttackData>) -> Void {
    let guard: Int32 = 0;
    while attackData.HasFlag(hitFlag.Nonlethal) && guard < 8 {
      attackData.RemoveFlag(hitFlag.Nonlethal);
      guard += 1;
    };
  }

  // Pax (Items.GenericMod1_LowTier / HighTier) sits in a weapon mod slot and adds Nonlethal through the same native
  // effector as the eyes, so it is told apart by the installed part, not by the flag's source name.
  public static func HasPax(attackData: ref<AttackData>) -> Bool {
    let weapon: wref<WeaponObject> = attackData.GetWeapon();
    if !IsDefined(weapon) {
      return false;
    };
    let parts: array<InnerItemData>;
    weapon.GetItemData().GetItemParts(parts);
    let i: Int32 = 0;
    while i < ArraySize(parts) {
      if StrContains(TDBID.ToStringDEBUG(ItemID.GetTDBID(InnerItemData.GetItemID(parts[i]))), "Items.GenericMod1_") {
        return true;
      };
      i += 1;
    };
    return false;
  }

  // Key off: only the eyes' entry goes. Mod-named entries and the attack records' own (PreAttack) stay.
  public static func StripEyes(attackData: ref<AttackData>) -> Void {
    if !Toggle.HasPax(attackData) {
      attackData.RemoveFlag(hitFlag.Nonlethal, n"AddHitFlagToAttackEffector");
    };
  }

  // 1.4.0: flash, smoke, EMP, recon and sonic grenades stay non-lethal; every other grenade kills (frag, incendiary,
  // biohazard, cutting, Ozob's, Misoru tornado = $base GrenadeCuttingRegular). Tags as in BaseGrenade.IsGrenadeOfType.
  public static func GrenadeIsLethal(grenade: ref<BaseGrenade>) -> Bool {
    let record: ref<Item_Record> = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(grenade.GetItemID()));
    if !IsDefined(record) {
      return true;
    };
    return !record.TagsContains(n"FlashGrenade") && !record.TagsContains(n"SmokeGrenade") && !record.TagsContains(n"EMPGrenade")
      && !record.TagsContains(n"ReconGrenade") && !record.TagsContains(n"SonicGrenade");
  }

  // 1.4.0: a lethal grenade's own attacks, or any other explosion
  public static func IsLethalBlast(attackData: ref<AttackData>) -> Bool {
    let grenade: ref<BaseGrenade> = attackData.GetSource() as BaseGrenade;
    if IsDefined(grenade) {
      return Toggle.GrenadeIsLethal(grenade);
    };
    return AttackData.IsExplosion(attackData.GetAttackType());
  }

  // 1.4.0: true for a lethal blast hit (and opens a 15 s window on the NPC) or a damage-over-time tick inside that window
  public static func KillsAnyway(npc: ref<NPCPuppet>, attackData: ref<AttackData>) -> Bool {
    let now: Float = EngineTime.ToFloat(GameInstance.GetSimTime(npc.GetGame()));
    if Toggle.IsLethalBlast(attackData) {
      npc.m_cyberslopBlastLethalUntil = now + 15.00;
      return true;
    };
    return (AttackData.IsDoT(attackData) || AttackData.IsEffect(attackData.GetAttackType())) && now < npc.m_cyberslopBlastLethalUntil;
  }

  // 1.6.0: true if the hit carries Nonlethal and every Nonlethal entry was put there by this mode or by the eyes' (or
  // Pax's) native effector; source gets the first entry's source name. Hits with an entry of another owner (Gorilla
  // Yeet, Push/Pull, Thunderclap, attack records) are left alone. Script AddFlag keeps one entry per flag; native code
  // might not, so all entries are checked (and StripNonlethal removes all of them).
  public static func ModeFlag(attackData: ref<AttackData>, out source: CName) -> Bool {
    let flags: array<SHitFlag> = attackData.GetFlags();
    let found: Bool = false;
    let i: Int32 = 0;
    while i < ArraySize(flags) {
      if Equals(flags[i].flag, hitFlag.Nonlethal) {
        if !Equals(flags[i].source, n"CyberslopEyeNonLethal") && !Equals(flags[i].source, n"AddHitFlagToAttackEffector") {
          return false;
        };
        if !found {
          source = flags[i].source;
          found = true;
        };
      };
      i += 1;
    };
    return found;
  }

  // 1.6.0: blasts keep the 1.4.0 rule, damage-over-time ticks and effects never cut
  public static func GoreAttack(attackData: ref<AttackData>) -> Bool {
    let kind: gamedataAttackType = attackData.GetAttackType();
    return !AttackData.IsExplosion(kind) && !AttackData.IsEffect(kind) && !AttackData.IsDoT(attackData);
  }

  // 1.6.0: 0 = no gore with the mode on (torso, nothing), 1 = limb (cut keeps the target alive), 2 = head (cut kills)
  public static func GoreZone(shape: ref<HitShapeUserDataBase>) -> Int32 {
    if !IsDefined(shape) {
      return 0;
    };
    if HitShapeUserDataBase.IsHitReactionZoneHead(shape) {
      return 2;
    };
    switch HitShapeUserDataBase.GetHitReactionZone(shape) {
      case EHitReactionZone.ArmLeft:
      case EHitReactionZone.HandLeft:
      case EHitReactionZone.ArmRight:
      case EHitReactionZone.HandRight:
      case EHitReactionZone.LegLeft:
      case EHitReactionZone.LegRight:
        return 1;
      default:
        return 0;
    };
  }

  private static func Show(game: GameInstance, text: String) -> Void {
    let message: SimpleScreenMessage;
    message.isShown = true;
    message.duration = 2.00;
    message.message = text;
    let defs: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
    GameInstance.GetBlackboardSystem(game).Get(defs.UI_Notifications).SetVariant(defs.UI_Notifications.OnscreenMessage, ToVariant(message), true);
  }
}

// 1.2.0: before the PreProcess stage. PDO reads the Nonlethal flag in ProcessLocalizedDamage, which vanilla PreProcess
// calls (ModifyHitData), so a flag added in Process (1.0.0 to 1.1.1) came too late: PDO ran its dying state on every
// knockout and its loop kept the body Invulnerable, and every later swing was zeroed by InvulnerabilityCheck, which
// also runs in PreProcess (fx=IJUD, invuln=1, pdo=true/true on every punch on the body). The mode's flag
// is now added here, and a finishing swing on a body PDO holds invulnerable gets IgnoreImmortalityModes, which makes
// InvulnerabilityCheck and ImmortalityCheck skip the hit.
@wrapMethod(DamageSystem)
private final func PreProcess(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Bool {
  let player: ref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
  let npc: ref<NPCPuppet> = hitEvent.target as NPCPuppet;
  if Toggle.IsHumanTarget(player, npc) {
    if Toggle.Finishes(npc, hitEvent.attackData) {
      Toggle.StripNonlethal(hitEvent.attackData);
      if Toggle.HeldInvulnerable(npc) {
        hitEvent.attackData.AddFlag(hitFlag.IgnoreImmortalityModes, n"CyberslopEyeNonLethal finish");
      };
    } else {
      if Toggle.Covers(player, npc) && Toggle.KillsAnyway(npc, hitEvent.attackData) {
        Toggle.StripEyes(hitEvent.attackData);
      } else {
        if Toggle.Spares(player, npc) {
          hitEvent.attackData.AddFlag(hitFlag.Nonlethal, n"CyberslopEyeNonLethal");
        };
      };
    };
  };
  return wrappedMethod(hitEvent, cache);
}

// Runs in the Process stage, after the eyes' effector and before the hit reaction reads the flags. The finishing
// strip runs again here for flags that arrived after PreProcess; key OFF, or a lethal blast (1.4.0), removes the
// eyes' own entry.
@wrapMethod(DamageSystem)
private final func Process(hitEvent: ref<gameHitEvent>, cache: ref<CacheData>) -> Void {
  let player: ref<PlayerPuppet> = hitEvent.attackData.GetInstigator() as PlayerPuppet;
  let npc: ref<NPCPuppet> = hitEvent.target as NPCPuppet;
  if Toggle.IsHumanTarget(player, npc) {
    if Toggle.Finishes(npc, hitEvent.attackData) {
      Toggle.StripNonlethal(hitEvent.attackData);
    } else {
      if Toggle.Covers(player, npc) && (!Toggle.IsOn(player.GetGame()) || Toggle.KillsAnyway(npc, hitEvent.attackData)) {
        Toggle.StripEyes(hitEvent.attackData);
      };
    };
  };
  wrappedMethod(hitEvent, cache);
}

// A dismemberment on a hit that empties the health bar kills in ProcessWoundsAndDismemberment, Nonlethal or not.
// 1.6.0: head and limb hits reach this without the mode's entry (wrap below), so it now only guards the rest.
@wrapMethod(HitReactionComponent)
protected final func DismembermentConditions() -> Bool {
  if this.m_attackData.HasFlag(hitFlag.Nonlethal) && Toggle.Spares(this.m_attackData.GetInstigator() as PlayerPuppet, this.m_ownerNPC) {
    return false;
  };
  return wrappedMethod();
}

// 1.6.0: gore with the mode on. zz_CyberslopEyeNonLethal sorts after CazanuLimbSurvival and
// zz_CyberslopDownedLimbCuts, so this wrap is the outer one: everything inside sees the hit without the entry.
@wrapMethod(HitReactionComponent)
protected final func ProcessWoundsAndDismemberment() -> Void {
  let npc: ref<NPCPuppet> = this.m_ownerNPC;
  let data: ref<AttackData> = this.m_attackData;
  let source: CName;
  let zone: Int32 = 0;
  // PDO-held body: a finishing hit (Toggle.Finishes) drops the hold first, the same way PDO's own finishing code does
  // (DamageUtils RemoveStatusEffect Invulnerable). Otherwise vanilla CanDieCondition reads IsInvulnerable and returns
  // before any gore (2026-11-23: monowire on a PDO body, invuln=1, no cut). If the body
  // still lives, PDO's loop re-applies the hold on its next tick.
  if IsDefined(npc) && IsDefined(data) && Toggle.IsHumanTarget(data.GetInstigator() as PlayerPuppet, npc)
    && Toggle.Finishes(npc, data) && Toggle.HeldInvulnerable(npc) {
    StatusEffectHelper.RemoveStatusEffect(npc, t"BaseStatusEffect.Invulnerable");
    this.m_currentIsInvulnerable = 0.00;
  };
  if IsDefined(npc) && IsDefined(data) && Toggle.Spares(data.GetInstigator() as PlayerPuppet, npc) && Toggle.GoreAttack(data)
    && Toggle.ModeFlag(data, source) {
    zone = Toggle.GoreZone(this.GetHitShapeUserData());
  };
  if zone == 0 {
    wrappedMethod();
    return;
  };
  let wasAlive: Bool = this.m_isAlive;
  let reaction: animHitReactionType = this.m_reactionType;
  let intensity: EAIHitIntensity = this.m_hitIntensity;
  Toggle.StripNonlethal(data);
  if zone == 1 {
    npc.m_cenlSpareKill = true;
    npc.m_cenlKillSkipped = false;
  };
  wrappedMethod();
  npc.m_cenlSpareKill = false;
  if !data.HasFlag(hitFlag.Nonlethal) {
    data.AddFlag(hitFlag.Nonlethal, source);
  };
  if npc.m_cenlKillSkipped {
    npc.m_cenlKillSkipped = false;
    this.m_isAlive = wasAlive;
    this.m_reactionType = reaction;
    this.m_hitIntensity = intensity;
  };
}

// Body perk Obliterate (shotgun / LMG / HMG execute, hitReactionComponent.swift 2201-2259) takes the head and more
// on any zone, then calls Kill: it stays lethal inside a spared limb hit, so no headless body is left alive.
@wrapMethod(HitReactionComponent)
protected final func ProcessBodyPerkDismembement() -> Void {
  let npc: ref<NPCPuppet> = this.m_ownerNPC;
  if !IsDefined(npc) || !npc.m_cenlSpareKill {
    wrappedMethod();
    return;
  };
  npc.m_cenlSpareKill = false;
  wrappedMethod();
  npc.m_cenlSpareKill = true;
}

@wrapMethod(NPCPuppet)
public func Kill(opt instigator: wref<GameObject>, opt skipNPCDeathAnim: Bool, opt disableNPCRagdoll: Bool) -> Void {
  if this.m_cenlSpareKill {
    this.m_cenlKillSkipped = true;
    return;
  };
  wrappedMethod(instigator, skipNPCDeathAnim, disableNPCRagdoll);
}

// 1.6.0: Relentless caps a limb hit's health damage (so the target keeps standing after the cut) only on hits without
// Nonlethal (LimbSurvival.reds CLS_PrepareFirstLimbDamage). It reads the flag here, at the start of
// StatPoolsManager.ApplyDamage; the entry is back before any damage is applied. Compiled only with Relentless present.
@if(ModuleExists("CazanuLimbSurvival"))
@wrapMethod(NPCPuppet)
private final func CLS_PrepareFirstLimbDamage(hit: ref<gameHitEvent>) -> Void {
  let source: CName;
  if !IsDefined(hit) || !IsDefined(hit.attackData) || !Toggle.Spares(hit.attackData.GetInstigator() as PlayerPuppet, this)
    || !Toggle.GoreAttack(hit.attackData) || !Toggle.ModeFlag(hit.attackData, source) {
    wrappedMethod(hit);
    return;
  };
  Toggle.StripNonlethal(hit.attackData);
  wrappedMethod(hit);
  if !hit.attackData.HasFlag(hitFlag.Nonlethal) {
    hit.attackData.AddFlag(hitFlag.Nonlethal, source);
  };
}

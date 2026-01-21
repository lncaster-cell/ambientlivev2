# ambientlivev2

## Документация

* [AUDIT.md](AUDIT.md) — аудит текущих механизмов, противоречий и рисков.
* [INSTALLATION.md](INSTALLATION.md) — инструкция установки для начинающих.

## Toolset bindings

* Area OnEnter: `AL_Area_OnEnter`
* Area OnExit: `AL_Area_OnExit`
* Module OnClientLeave: `AL_Module_OnClientLeave`
* NPC OnSpawn (registration): `AL_NPC_OnSpawn`
* NPC OnDeath (unregister): `AL_NPC_OnDeath`
* NPC OnUserDefined: `AL_NPC_OnUserDefined`

## Role activity defaults

You can assign a role to an NPC by setting the local int `al_role` in the toolset.
On spawn the system will map that role to a default activity and fill slots `a0..a5` with
the matching activity ID. This happens once per NPC and marks `al_role_applied` so custom
slot values can still be set manually afterwards.

Available roles are declared in `AL_Role_Activities_Inc`:

* `AL_ROLE_BARTENDER`, `AL_ROLE_BARMAID`, `AL_ROLE_LIGHT_KEEPER`
* `AL_ROLE_SMITH`, `AL_ROLE_COOK`, `AL_ROLE_MUSICIAN`
* `AL_ROLE_TRAINER`, `AL_ROLE_THIEF`, `AL_ROLE_MERCHANT`
* `AL_ROLE_GUARD`, `AL_ROLE_CITIZEN`

## Dynamic slot updates

If you change an NPC activity slot (`a0..a5`) at runtime, call
`AL_RefreshRouteForSlot(oNpc, nSlot)` afterwards to cache the waypoint route
for that slot. Slot routes (`AL_WP_S0..AL_WP_S5`) apply to any activity and take
priority over activity-specific routes. This keeps route changes in sync
without needing to respawn the NPC.

### Example

Attach the scripts in the toolset event slots:

* Area events:
  * OnEnter → `AL_Area_OnEnter`
  * OnExit → `AL_Area_OnExit`
  * OnHeartbeat → leave empty (system uses AreaTick via DelayCommand)
* Module events:
  * OnClientLeave → `AL_Module_OnClientLeave`
* NPC events:
  * OnSpawn → `AL_NPC_OnSpawn`
  * OnDeath → `AL_NPC_OnDeath`
  * OnUserDefined → `AL_NPC_OnUserDefined`

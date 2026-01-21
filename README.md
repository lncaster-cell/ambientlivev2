# ambientlivev2

## Toolset bindings

* Area OnEnter: `AL_Area_OnEnter`
* Area OnExit: `AL_Area_OnExit`
* NPC OnSpawn (registration): `AL_NPC_OnSpawn`
* NPC OnDeath (unregister): `AL_NPC_OnDeath`
* NPC OnUserDefined: `AL_NPC_OnUserDefined`

### Example

Attach the scripts in the toolset event slots:

* Area events:
  * OnEnter → `AL_Area_OnEnter`
  * OnExit → `AL_Area_OnExit`
  * OnHeartbeat → leave empty (system uses AreaTick via DelayCommand)
* NPC events:
  * OnSpawn → `AL_NPC_OnSpawn`
  * OnDeath → `AL_NPC_OnDeath`
  * OnUserDefined → `AL_NPC_OnUserDefined`

// NPC OnDeath: attach to NPC OnDeath in the toolset.

#include "AL_NPC_Registry_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    AL_UnregisterNPC(oNpc);
}

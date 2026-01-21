// NPC OnDeath: attach to NPC OnDeath in the toolset.

#include "al_npc_registry_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    string sTag = GetTag(oNpc);
    if (sTag == "FACTION_NPC1" || sTag == "FACTION_NPC2")
    {
        object oArea = GetArea(oNpc);
        if (GetIsObjectValid(oArea))
        {
            if (sTag == "FACTION_NPC1")
            {
                DeleteLocalObject(oArea, "al_training_npc1");
            }
            else
            {
                DeleteLocalObject(oArea, "al_training_npc2");
            }
            SetLocalInt(oArea, "al_training_partner_cached", FALSE);
        }
    }
    AL_UnregisterNPC(oNpc);
}

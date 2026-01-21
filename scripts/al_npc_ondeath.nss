// NPC OnDeath: attach to NPC OnDeath in the toolset.

#include "al_npc_reg_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    object oPartner = GetLocalObject(oNpc, "al_training_partner");
    if (GetIsObjectValid(oPartner))
    {
        DeleteLocalObject(oPartner, "al_training_partner");
    }
    DeleteLocalObject(oNpc, "al_training_partner");

    object oBarPair = GetLocalObject(oNpc, "al_bar_pair");
    if (GetIsObjectValid(oBarPair))
    {
        DeleteLocalObject(oBarPair, "al_bar_pair");
    }
    DeleteLocalObject(oNpc, "al_bar_pair");

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

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        if (GetLocalObject(oArea, "al_bar_bartender") == oNpc)
        {
            DeleteLocalObject(oArea, "al_bar_bartender");
        }
        if (GetLocalObject(oArea, "al_bar_barmaid") == oNpc)
        {
            DeleteLocalObject(oArea, "al_bar_barmaid");
        }
    }
    AL_UnregisterNPC(oNpc);
}

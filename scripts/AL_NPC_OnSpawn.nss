// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

#include "AL_Constants_Inc"
#include "AL_NPC_Registry_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "l", -1);

    AL_RegisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        int iSlotCount = GetLocalInt(oArea, "p");
        if (iSlotCount > 0)
        {
            if (GetScriptHidden(oNpc))
            {
                SetScriptHidden(oNpc, FALSE, TRUE);
            }
            SignalEvent(oNpc, EventUserDefined(AL_EVT_RESYNC));
        }
        else
        {
            SetScriptHidden(oNpc, TRUE, TRUE);
        }
    }
}

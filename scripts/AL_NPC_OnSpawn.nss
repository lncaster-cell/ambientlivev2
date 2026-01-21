// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

#include "AL_Constants_Inc"
#include "AL_NPC_Registry_Inc"
#include "AL_Role_Activities_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "l", -1);
    AL_ApplyRoleActivities(oNpc);

    AL_RegisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        int iSlotCount = GetLocalInt(oArea, "p");
        if (iSlotCount > 0)
        {
            if (GetScriptHidden(oNpc))
            {
                SetScriptHidden(oNpc, FALSE, FALSE);
            }
            SignalEvent(oNpc, EventUserDefined(AL_EVT_RESYNC));
        }
        else
        {
            SetScriptHidden(oNpc, TRUE, TRUE);
        }
    }
}

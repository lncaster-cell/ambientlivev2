// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

#include "AL_Constants_Inc"
#include "AL_NPC_Activities_Inc"
#include "AL_NPC_Registry_Inc"
#include "AL_Role_Activities_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "l", -1);
    AL_ApplyRoleActivities(oNpc);
    int iSlot = 0;

    while (iSlot <= AL_SLOT_MAX)
    {
        string sSlotTag = "AL_WP_S" + IntToString(iSlot);
        int iCount = AL_CacheRouteFromTag(oNpc, iSlot, sSlotTag);

        if (iCount <= 0)
        {
            int nActivity = AL_GetActivityForSlot(oNpc, iSlot);
            string sWaypointTag = AL_GetActivityWaypointTag(nActivity);

            if (sWaypointTag != "")
            {
                AL_CacheRouteFromTag(oNpc, iSlot, sWaypointTag);
            }
        }

        iSlot++;
    }

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

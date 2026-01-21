// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

#include "AL_Constants_Inc"
#include "AL_NPC_Activities_Inc"
#include "AL_NPC_Routes_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    int nEvent = GetUserDefinedEventNumber();
    int nSlot = -1;

    if (nEvent == AL_EVT_RESYNC)
    {
        object oArea = GetArea(oNpc);
        if (GetIsObjectValid(oArea))
        {
            nSlot = GetLocalInt(oArea, "s");
        }
    }
    else if (nEvent >= AL_EVT_SLOT_0 && nEvent <= AL_EVT_SLOT_5)
    {
        nSlot = nEvent - AL_EVT_SLOT_BASE;
    }
    else if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        nSlot = GetLocalInt(oNpc, "r_slot");
    }
    else
    {
        return;
    }

    if (nSlot < 0 || nSlot > AL_SLOT_MAX)
    {
        return;
    }

    if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        if (GetLocalInt(oNpc, "l") != nSlot)
        {
            return;
        }
    }
    else if (nEvent != AL_EVT_RESYNC && GetLocalInt(oNpc, "l") == nSlot)
    {
        return;
    }

    SetLocalInt(oNpc, "l", nSlot);
    AL_QueueRoute(oNpc, nSlot, nEvent != AL_EVT_ROUTE_REPEAT);
    AL_ApplyActivityForSlot(oNpc, nSlot);
}

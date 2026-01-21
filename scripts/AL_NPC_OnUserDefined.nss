// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

#include "AL_NPC_Routes_Inc"

void main()
{
    object oNpc = OBJECT_SELF;
    int nEvent = GetUserDefinedEventNumber();
    int nSlot = -1;

    if (nEvent == 3006)
    {
        object oArea = GetArea(oNpc);
        if (GetIsObjectValid(oArea))
        {
            nSlot = GetLocalInt(oArea, "s");
        }
    }
    else if (nEvent >= 3000 && nEvent <= 3005)
    {
        nSlot = nEvent - 3000;
    }
    else if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        nSlot = GetLocalInt(oNpc, "r_slot");
    }
    else
    {
        return;
    }

    if (nSlot < 0 || nSlot > 5)
    {
        return;
    }

    if (nEvent != AL_EVT_ROUTE_REPEAT && GetLocalInt(oNpc, "l") == nSlot)
    {
        return;
    }

    SetLocalInt(oNpc, "l", nSlot);

    if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        AL_QueueRoute(oNpc, nSlot, FALSE);
        return;
    }

    AL_QueueRoute(oNpc, nSlot, TRUE);
}

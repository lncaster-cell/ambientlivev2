#include "AL_Constants_Inc"
#include "AL_NPC_Registry_Inc"

// Shared Area tick helper: scheduled every 45s while players are present.
// NPC registry synchronization is handled here at the area level only.

const float AL_TICK_PERIOD = 45.0;

int AL_ComputeTimeSlot()
{
    int iSlot = GetTimeHour() / 4;
    if (iSlot < 0)
    {
        iSlot = 0;
    }
    else if (iSlot > AL_SLOT_MAX)
    {
        iSlot = AL_SLOT_MAX;
    }

    return iSlot;
}

void AreaTick(object oArea, int nToken)
{
    if (GetLocalInt(oArea, "p") <= 0)
    {
        return;
    }

    if (nToken != GetLocalInt(oArea, "t"))
    {
        return;
    }

    AL_SyncAreaNPCRegistry(oArea);

    int iSlot = AL_ComputeTimeSlot();

    if (iSlot == GetLocalInt(oArea, "s"))
    {
        DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
        return;
    }

    SetLocalInt(oArea, "s", iSlot);
    AL_BroadcastUserEvent(oArea, AL_EVT_SLOT_BASE + iSlot);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
}

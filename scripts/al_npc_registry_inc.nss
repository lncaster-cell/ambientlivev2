// NPC registry helpers: dense array locals n, n0..n99 on areas.
// Registry synchronization runs only at the area level (see AreaTick).

#include "al_constants_inc"

int AL_PruneRegistrySlot(object oArea, int iIndex, int iCount)
{
    int iLastIndex = iCount - 1;

    if (iLastIndex < 0)
    {
        return 0;
    }

    if (iIndex != iLastIndex)
    {
        object oSwap = GetLocalObject(oArea, "n" + IntToString(iLastIndex));
        SetLocalObject(oArea, "n" + IntToString(iIndex), oSwap);
    }

    DeleteLocalObject(oArea, "n" + IntToString(iLastIndex));
    iCount--;
    SetLocalInt(oArea, "n", iCount);
    return iCount;
}

void AL_RegisterNPC(object oNpc)
{
    object oArea = GetArea(oNpc);

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalObject(oNpc, "al_last_area", oArea);

    int iCount = GetLocalInt(oArea, "n");
    int iIndex = 0;

    while (iIndex < iCount)
    {
        object oEntry = GetLocalObject(oArea, "n" + IntToString(iIndex));

        if (!GetIsObjectValid(oEntry))
        {
            iCount = AL_PruneRegistrySlot(oArea, iIndex, iCount);
            continue;
        }

        if (oEntry == oNpc)
        {
            return;
        }

        iIndex++;
    }

    if (iCount >= AL_MAX_NPCS)
    {
        return;
    }

    SetLocalObject(oArea, "n" + IntToString(iCount), oNpc);
    SetLocalInt(oArea, "n", iCount + 1);
}

void AL_UnregisterNPC(object oNpc)
{
    object oArea = GetLocalObject(oNpc, "al_last_area");

    if (!GetIsObjectValid(oArea))
    {
        oArea = GetArea(oNpc);
    }

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int iCount = GetLocalInt(oArea, "n");
    int iIndex = 0;

    while (iIndex < iCount)
    {
        object oEntry = GetLocalObject(oArea, "n" + IntToString(iIndex));

        if (oEntry == oNpc)
        {
            AL_PruneRegistrySlot(oArea, iIndex, iCount);
            return;
        }

        iIndex++;
    }
}

void AL_SyncAreaNPCRegistry(object oArea)
{
    int iCount = GetLocalInt(oArea, "n");
    int i = 0;

    while (i < iCount)
    {
        string sKey = "n" + IntToString(i);
        object oNpc = GetLocalObject(oArea, sKey);

        if (!GetIsObjectValid(oNpc))
        {
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            continue;
        }

        object oCurrentArea = GetArea(oNpc);
        if (!GetIsObjectValid(oCurrentArea))
        {
            DeleteLocalObject(oNpc, "al_last_area");
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            continue;
        }

        if (oCurrentArea != oArea)
        {
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            SetLocalObject(oNpc, "al_last_area", oCurrentArea);
            AL_RegisterNPC(oNpc);
            continue;
        }

        SetLocalObject(oNpc, "al_last_area", oArea);
        i++;
    }
}

void AL_StartNPCRegistryTracking(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        SetLocalObject(oNpc, "al_last_area", oArea);
    }
}

void AL_HideRegisteredNPCs(object oArea)
{
    int iCount = GetLocalInt(oArea, "n");
    int i = 0;

    while (i < iCount)
    {
        string sKey = "n" + IntToString(i);
        object oNpc = GetLocalObject(oArea, sKey);

        if (!GetIsObjectValid(oNpc))
        {
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            continue;
        }

        if (AL_CLEAR_ACTIONS_ON_DEACTIVATE)
        {
            AssignCommand(oNpc, ClearAllActions());
        }

        SetScriptHidden(oNpc, TRUE, TRUE);
        i++;
    }
}

void AL_UnhideAndResyncRegisteredNPCs(object oArea)
{
    int iCount = GetLocalInt(oArea, "n");
    int i = 0;

    while (i < iCount)
    {
        string sKey = "n" + IntToString(i);
        object oNpc = GetLocalObject(oArea, sKey);

        if (!GetIsObjectValid(oNpc))
        {
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            continue;
        }

        SetScriptHidden(oNpc, FALSE, FALSE);
        SignalEvent(oNpc, EventUserDefined(AL_EVT_RESYNC));
        i++;
    }
}

void AL_BroadcastUserEvent(object oArea, int nEvent)
{
    int iCount = GetLocalInt(oArea, "n");
    int i = 0;

    while (i < iCount)
    {
        string sKey = "n" + IntToString(i);
        object oNpc = GetLocalObject(oArea, sKey);

        if (!GetIsObjectValid(oNpc))
        {
            iCount = AL_PruneRegistrySlot(oArea, i, iCount);
            continue;
        }

        SignalEvent(oNpc, EventUserDefined(nEvent));
        i++;
    }
}

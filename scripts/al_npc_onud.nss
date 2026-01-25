// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

#include "al_constants_inc"
#include "al_npc_acts_inc"

void AL_ResetRouteIndex(object oNpc);
int AL_ActivityUsesRoute(object oNpc, int nSlot);

int AL_GetAmbientLifeDaySeconds()
{
    int nSeconds = GetTimeSecond();
    int nMinutes = GetTimeMinute();
    int nHours = GetTimeHour();

    return nSeconds + (nMinutes * 60) + (nHours * 3600);
}

void AL_ResetRouteIndex(object oNpc)
{
    SetLocalInt(oNpc, "r_idx", 0);
}

int AL_ActivityUsesRoute(object oNpc, int nSlot)
{
    return AL_GetRouteCount(oNpc, nSlot) > 0;
}

int AL_GetRepeatAnimIntervalSeconds()
{
    return 15 + Random(16);
}

int AL_IsRepeatAnimCoolingDown(object oNpc)
{
    int nNext = GetLocalInt(oNpc, "al_anim_next");
    if (nNext <= 0)
    {
        return FALSE;
    }

    int nNow = AL_GetAmbientLifeDaySeconds();
    int nDelta = (nNext - nNow + 86400) % 86400;
    return nDelta > 0 && nDelta < 43200;
}

void AL_MarkAnimationApplied(object oNpc, int nIntervalSeconds)
{
    int nNow = AL_GetAmbientLifeDaySeconds();
    int nNext = (nNow + nIntervalSeconds) % 86400;
    SetLocalInt(oNpc, "al_anim_next", nNext);
}

void AL_DebugLog(object oNpc, string sMessage)
{
    if (GetLocalInt(oNpc, "al_debug") != 1)
    {
        object oArea = GetArea(oNpc);
        if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_debug") != 1)
        {
            return;
        }
    }

    object oPc = GetFirstPC();
    if (GetIsObjectValid(oPc))
    {
        SendMessageToPC(oPc, sMessage);
    }
}

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
            nSlot = GetLocalInt(oArea, "al_slot");
        }

    }
    else if (nEvent >= AL_EVT_SLOT_0 && nEvent <= AL_EVT_SLOT_5)
    {
        nSlot = nEvent - AL_EVT_SLOT_0;
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
        int nRouteActive = GetLocalInt(oNpc, "r_active");
        if (nRouteActive == FALSE || AL_GetRouteCount(oNpc, nSlot) <= 0)
        {
            return;
        }

        if (GetLocalInt(oNpc, "al_last_slot") != nSlot)
        {
            return;
        }
    }
    else if (nEvent != AL_EVT_RESYNC && GetLocalInt(oNpc, "al_last_slot") == nSlot)
    {
        return;
    }

    if (nEvent == AL_EVT_RESYNC)
    {
        SetLocalInt(oNpc, "al_last_slot", -1);
    }

    AL_RefreshRouteForSlot(oNpc, nSlot);
    if (nEvent != AL_EVT_ROUTE_REPEAT)
    {
        AL_ResetRouteIndex(oNpc);
    }

    SetLocalInt(oNpc, "al_last_slot", nSlot);
    int nActivity = AL_GetWaypointActivityForSlot(oNpc, nSlot);
    int bUsesRoute = AL_ActivityUsesRoute(oNpc, nSlot);
    int bRequiresRouteTag = AL_GetActivityWaypointTag(nActivity) != "";
    int bHasRequiredRoute = AL_ActivityHasRequiredRoute(oNpc, nSlot, nActivity);
    int bCanUseRoute = bUsesRoute && bHasRequiredRoute;
    AL_DebugLog(oNpc, "AL_EVT " + IntToString(nEvent)
        + " slot=" + IntToString(nSlot)
        + " activity=" + IntToString(nActivity));
    if (nActivity == AL_ACT_NPC_HIDDEN)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
        return;
    }
    if (nEvent == AL_EVT_ROUTE_REPEAT && !bCanUseRoute)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
        return;
    }

    int bSleepActivity = AL_ShouldLoopCustomAnimation(nActivity);
    if (!bCanUseRoute)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
    }
    AL_DebugLog(oNpc, "routeCount=" + IntToString(AL_GetRouteCount(oNpc, nSlot))
        + " requiresRoute=" + IntToString(bRequiresRouteTag)
        + " usesRoute=" + IntToString(bUsesRoute)
        + " hasRequiredRoute=" + IntToString(bHasRequiredRoute)
        + " sleep=" + IntToString(bSleepActivity));

    int bSkipMoveRepeat = FALSE;
    if (bCanUseRoute && nEvent == AL_EVT_ROUTE_REPEAT && AL_GetRouteCount(oNpc, nSlot) == 1)
    {
        bSkipMoveRepeat = TRUE;
    }

    if (bCanUseRoute)
    {
        if (bSleepActivity && nEvent == AL_EVT_ROUTE_REPEAT)
        {
            AL_ClearActiveRoute(oNpc, /*bClearActions=*/ FALSE);
        }
        else if (bSkipMoveRepeat)
        {
            float fRepeatDelay = 5.0 + IntToFloat(Random(8));

            AssignCommand(oNpc, ActionWait(fRepeatDelay));
            AssignCommand(oNpc, ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVT_ROUTE_REPEAT))));
        }
        else
        {
            AL_QueueRoute(oNpc, nSlot, nEvent != AL_EVT_ROUTE_REPEAT);
        }
    }

    int bAllowAnimation = TRUE;
    if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        if (AL_IsRepeatAnimCoolingDown(oNpc))
        {
            bAllowAnimation = FALSE;
        }
    }

    int bShouldPlay = bAllowAnimation;
    if (bCanUseRoute && nEvent != AL_EVT_ROUTE_REPEAT)
    {
        bShouldPlay = FALSE;
    }

    if (bShouldPlay)
    {
        int nIntervalSeconds = AL_GetRepeatAnimIntervalSeconds();
        AL_ApplyActivityForSlot(oNpc, nSlot);
        AL_MarkAnimationApplied(oNpc, nIntervalSeconds);
    }
}

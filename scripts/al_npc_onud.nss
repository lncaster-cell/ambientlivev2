// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

#include "al_constants_inc"
#include "al_npc_acts_inc"
#include "al_npc_routes"

int AL_GetAmbientLifeDaySeconds()
{
    int nSeconds = GetTimeSecond();
    int nMinutes = GetTimeMinute();
    int nHours = GetTimeHour();

    return nSeconds + (nMinutes * 60) + (nHours * 3600);
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

void AL_HandleResyncSlotOverrides(object oNpc)
{
    string sA0 = GetLocalString(oNpc, "a0");
    string sA1 = GetLocalString(oNpc, "a1");
    string sA2 = GetLocalString(oNpc, "a2");
    string sA3 = GetLocalString(oNpc, "a3");
    string sA4 = GetLocalString(oNpc, "a4");
    string sA5 = GetLocalString(oNpc, "a5");
    int nA0 = AL_GetActivitySlotInt(oNpc, 0);
    int nA1 = AL_GetActivitySlotInt(oNpc, 1);
    int nA2 = AL_GetActivitySlotInt(oNpc, 2);
    int nA3 = AL_GetActivitySlotInt(oNpc, 3);
    int nA4 = AL_GetActivitySlotInt(oNpc, 4);
    int nA5 = AL_GetActivitySlotInt(oNpc, 5);
    int bHasSlotOverride = sA0 != ""
        || sA1 != ""
        || sA2 != ""
        || sA3 != ""
        || sA4 != ""
        || sA5 != "";

    if (bHasSlotOverride)
    {
        SetLocalInt(oNpc, "al_role_applied", FALSE);
    }

    string sLogA0 = sA0 != "" ? sA0 : IntToString(nA0);
    string sLogA1 = sA1 != "" ? sA1 : IntToString(nA1);
    string sLogA2 = sA2 != "" ? sA2 : IntToString(nA2);
    string sLogA3 = sA3 != "" ? sA3 : IntToString(nA3);
    string sLogA4 = sA4 != "" ? sA4 : IntToString(nA4);
    string sLogA5 = sA5 != "" ? sA5 : IntToString(nA5);
    AL_DebugLog(oNpc, "resync slots a0=" + sLogA0
        + " a1=" + sLogA1
        + " a2=" + sLogA2
        + " a3=" + sLogA3
        + " a4=" + sLogA4
        + " a5=" + sLogA5
        + " override=" + IntToString(bHasSlotOverride));
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

        AL_HandleResyncSlotOverrides(oNpc);
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

    SetLocalInt(oNpc, "al_last_slot", nSlot);
    int nActivity = AL_GetActivityForSlot(oNpc, nSlot);
    AL_DebugLog(oNpc, "AL_EVT " + IntToString(nEvent)
        + " slot=" + IntToString(nSlot)
        + " activity=" + IntToString(nActivity));
    if (nActivity == AL_ACT_NPC_HIDDEN)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
        return;
    }

    AL_RefreshRouteForSlot(oNpc, nSlot);

    int bRequiresRoute = AL_ActivityHasRequiredRoute(oNpc, nSlot, nActivity);
    int bSleepActivity = AL_ShouldLoopCustomAnimation(nActivity);
    if (bRequiresRoute && AL_GetRouteCount(oNpc, nSlot) <= 0)
    {
        bRequiresRoute = FALSE;
    }
    AL_DebugLog(oNpc, "routeCount=" + IntToString(AL_GetRouteCount(oNpc, nSlot))
        + " requiresRoute=" + IntToString(bRequiresRoute)
        + " sleep=" + IntToString(bSleepActivity));
    if (!bRequiresRoute && nEvent != AL_EVT_ROUTE_REPEAT)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
    }

    int bSkipMoveRepeat = FALSE;
    if (bRequiresRoute && nEvent == AL_EVT_ROUTE_REPEAT && AL_GetRouteCount(oNpc, nSlot) == 1)
    {
        bSkipMoveRepeat = TRUE;
    }

    if (bRequiresRoute)
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
    if (bRequiresRoute && nEvent != AL_EVT_ROUTE_REPEAT)
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

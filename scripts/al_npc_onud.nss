// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

#include "al_constants_inc"
#include "al_npc_acts_inc"
#include "al_npc_routes"

int AL_GetAmbientLifeTimestamp()
{
    int nSeconds = GetTimeSecond();
    int nMinutes = GetTimeMinute();
    int nHours = GetTimeHour();
    int nDays = GetCalendarDay();
    int nMonths = GetCalendarMonth();
    int nYears = GetCalendarYear();

    return nSeconds
        + (nMinutes * 60)
        + (nHours * 3600)
        + (nDays * 86400)
        + (nMonths * 2678400)
        + (nYears * 32140800);
}

int AL_GetRepeatAnimCooldownSeconds(int nRouteCount)
{
    if (nRouteCount <= 1)
    {
        return 6;
    }
    if (nRouteCount == 2)
    {
        return 4;
    }

    return 3;
}

int AL_IsRepeatAnimCoolingDown(object oNpc, int nCooldownSeconds)
{
    int nLast = GetLocalInt(oNpc, "al_last_anim_time");
    if (nLast <= 0)
    {
        return FALSE;
    }

    int nNow = AL_GetAmbientLifeTimestamp();
    return (nNow - nLast) < nCooldownSeconds;
}

void AL_MarkAnimationApplied(object oNpc)
{
    SetLocalInt(oNpc, "al_last_anim_time", AL_GetAmbientLifeTimestamp());
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
    if (nActivity == AL_ACT_NPC_HIDDEN)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
        return;
    }

    AL_RefreshRouteForSlot(oNpc, nSlot);

    int bRequiresRoute = AL_ActivityHasRequiredRoute(oNpc, nSlot, nActivity);
    if (bRequiresRoute && AL_GetRouteCount(oNpc, nSlot) <= 0)
    {
        bRequiresRoute = FALSE;
    }
    if (!bRequiresRoute && nEvent != AL_EVT_ROUTE_REPEAT)
    {
        AL_ClearActiveRoute(oNpc, /*bClearActions=*/ TRUE);
    }

    if (bRequiresRoute)
    {
        AL_QueueRoute(oNpc, nSlot, nEvent != AL_EVT_ROUTE_REPEAT);
    }

    int bAllowAnimation = TRUE;
    if (nEvent == AL_EVT_ROUTE_REPEAT)
    {
        int nCooldownSeconds = AL_GetRepeatAnimCooldownSeconds(AL_GetRouteCount(oNpc, nSlot));
        if (AL_IsRepeatAnimCoolingDown(oNpc, nCooldownSeconds))
        {
            bAllowAnimation = FALSE;
        }
    }

    if (bAllowAnimation)
    {
        AL_ApplyActivityForSlot(oNpc, nSlot);
        AL_MarkAnimationApplied(oNpc);
    }
}

// NPC activity helpers: apply per-slot activity animations without tag searches.

#include "al_acts_inc"
#include "al_constants_inc"
#include "al_npc_routes"

string AL_GetActivitySlotKey(int nSlot)
{
    return "a" + IntToString(nSlot);
}

int AL_GetActivityForSlot(object oNpc, int nSlot)
{
    return GetLocalInt(oNpc, AL_GetActivitySlotKey(nSlot));
}

string AL_TrimToken(string sToken)
{
    int iLen = GetStringLength(sToken);
    int iStart = 0;
    int iEnd = iLen - 1;

    while (iStart <= iEnd && GetSubString(sToken, iStart, 1) == " ")
    {
        iStart++;
    }

    while (iEnd >= iStart && GetSubString(sToken, iEnd, 1) == " ")
    {
        iEnd--;
    }

    if (iEnd < iStart)
    {
        return "";
    }

    return GetSubString(sToken, iStart, iEnd - iStart + 1);
}

string AL_SelectRandomToken(string sList)
{
    if (sList == "")
    {
        return "";
    }

    int i = 0;
    int iLen = GetStringLength(sList);
    int iStart = 0;
    int iToken = 0;
    string sSelected = "";

    while (i <= iLen)
    {
        if (i == iLen || GetSubString(sList, i, 1) == ",")
        {
            string sToken = AL_TrimToken(GetSubString(sList, iStart, i - iStart));
            iToken++;
            if (Random(iToken) == 0)
            {
                sSelected = sToken;
            }
            iStart = i + 1;
        }
        i++;
    }

    return sSelected;
}

void AL_PlayCustomAnimation(object oNpc, string sAnimation)
{
    if (sAnimation == "")
    {
        return;
    }

    PlayCustomAnimation(oNpc, sAnimation, TRUE, 1.0);
}

void AL_PlayNumericAnimation(int nAnimation)
{
    if (nAnimation <= 0)
    {
        return;
    }

    ActionPlayAnimation(nAnimation, 1.0, 1.0);
}

// Requirement checks avoid tag searches by relying on prebuilt locals/routes:
// - Routes for pacing/WWP use locals r<slot>_n / r<slot>_<idx> (see AL_NPC_Routes_Inc).
// - Training partners are set via local object "al_training_partner" on the NPC.
// - Bar pair NPCs are set via local object "al_bar_pair" on the NPC.
int AL_ActivityHasRequiredRoute(object oNpc, int nSlot, int nActivity)
{
    string sWaypointTag = AL_GetActivityWaypointTag(nActivity);
    if (sWaypointTag == "")
    {
        return TRUE;
    }

    return AL_GetRouteCount(oNpc, nSlot) > 0;
}

void AL_RefreshRouteForSlot(object oNpc, int nSlot)
{
    if (nSlot < 0 || nSlot > AL_SLOT_MAX)
    {
        return;
    }

    if (AL_GetRouteCount(oNpc, nSlot) <= 0)
    {
        string sSlotTag = "AL_WP_S" + IntToString(nSlot);
        if (AL_CacheRouteFromTag(oNpc, nSlot, sSlotTag) > 0)
        {
            return;
        }
    }

    int nActivity = AL_GetActivityForSlot(oNpc, nSlot);
    string sWaypointTag = AL_GetActivityWaypointTag(nActivity);

    if (sWaypointTag == "")
    {
        return;
    }

    if (AL_GetRouteCount(oNpc, nSlot) <= 0)
    {
        AL_CacheRouteFromTag(oNpc, nSlot, sWaypointTag);
    }
}

int AL_ActivityHasTrainingPartner(object oNpc)
{
    return GetIsObjectValid(GetLocalObject(oNpc, "al_training_partner"));
}

int AL_ActivityHasBarPair(object oNpc)
{
    return GetIsObjectValid(GetLocalObject(oNpc, "al_bar_pair"));
}

void AL_ApplyActivityForSlot(object oNpc, int nSlot)
{
    if (nSlot < 0 || nSlot > AL_SLOT_MAX)
    {
        return;
    }

    int nActivity = AL_GetActivityForSlot(oNpc, nSlot);

    if (nActivity == AL_ACT_NPC_HIDDEN)
    {
        return;
    }

    int bNeedsTrainingPartner = AL_ActivityRequiresTrainingPartner(nActivity);
    int bNeedsBarPair = AL_ActivityRequiresBarPair(nActivity);

    if (!AL_ActivityHasRequiredRoute(oNpc, nSlot, nActivity)
        || (bNeedsTrainingPartner && !AL_ActivityHasTrainingPartner(oNpc))
        || (bNeedsBarPair && !AL_ActivityHasBarPair(oNpc)))
    {
        nActivity = AL_ACT_NPC_ACT_ONE;
    }

    int bLocateWrapper = AL_IsLocateWrapperActivity(nActivity);
    string sCustom = bLocateWrapper
        ? AL_GetLocateWrapperCustomAnims(nActivity)
        : AL_GetActivityCustomAnims(nActivity);
    string sNumeric = bLocateWrapper
        ? AL_GetLocateWrapperNumericAnims(nActivity)
        : AL_GetActivityNumericAnims(nActivity);

    if (sCustom != "")
    {
        string sAnim = AL_SelectRandomToken(sCustom);
        AL_PlayCustomAnimation(oNpc, sAnim);
        return;
    }

    if (sNumeric != "")
    {
        string sAnimId = AL_SelectRandomToken(sNumeric);
        int nAnimId = StringToInt(sAnimId);
        AL_PlayNumericAnimation(nAnimId);
    }
}

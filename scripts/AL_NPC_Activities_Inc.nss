// NPC activity helpers: apply per-slot activity animations without tag searches.

#include "AL_Activities_Inc"
#include "AL_Constants_Inc"
#include "AL_NPC_Routes_Inc"

string AL_GetActivitySlotKey(int nSlot)
{
    return "a" + IntToString(nSlot);
}

int AL_GetActivityForSlot(object oNpc, int nSlot)
{
    return GetLocalInt(oNpc, AL_GetActivitySlotKey(nSlot));
}

int AL_CountTokens(string sList)
{
    if (sList == "")
    {
        return 0;
    }

    int iCount = 1;
    int i = 0;
    int iLen = GetStringLength(sList);

    while (i < iLen)
    {
        if (GetSubString(sList, i, 1) == ",")
        {
            iCount++;
        }
        i++;
    }

    return iCount;
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

string AL_GetTokenAt(string sList, int nIndex)
{
    int i = 0;
    int iLen = GetStringLength(sList);
    int iStart = 0;
    int iToken = 0;

    while (i <= iLen)
    {
        if (i == iLen || GetSubString(sList, i, 1) == ",")
        {
            if (iToken == nIndex)
            {
                return AL_TrimToken(GetSubString(sList, iStart, i - iStart));
            }
            iToken++;
            iStart = i + 1;
        }
        i++;
    }

    return "";
}

string AL_SelectRandomToken(string sList)
{
    int iCount = AL_CountTokens(sList);

    if (iCount <= 0)
    {
        return "";
    }

    int iIndex = Random(iCount);
    return AL_GetTokenAt(sList, iIndex);
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
int AL_ActivityHasRequiredRoute(object oNpc, int nSlot, string sWaypointTag)
{
    if (sWaypointTag == "")
    {
        return TRUE;
    }

    return AL_GetRouteCount(oNpc, nSlot) > 0;
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

    string sWaypointTag = AL_GetActivityWaypointTag(nActivity);
    int bNeedsTrainingPartner = AL_ActivityRequiresTrainingPartner(nActivity);
    int bNeedsBarPair = AL_ActivityRequiresBarPair(nActivity);

    if (!AL_ActivityHasRequiredRoute(oNpc, nSlot, sWaypointTag)
        || (bNeedsTrainingPartner && !AL_ActivityHasTrainingPartner(oNpc))
        || (bNeedsBarPair && !AL_ActivityHasBarPair(oNpc)))
    {
        nActivity = AL_ACT_NPC_ACT_ONE;
    }

    string sCustom = AL_GetActivityCustomAnims(nActivity);
    string sNumeric = AL_GetActivityNumericAnims(nActivity);

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

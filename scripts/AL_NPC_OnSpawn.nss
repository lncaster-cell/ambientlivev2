// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

#include "AL_Constants_Inc"
#include "AL_NPC_Activities_Inc"
#include "AL_NPC_Registry_Inc"
#include "AL_Role_Activities_Inc"

void AL_InitTrainingPartner(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetIsObjectValid(GetLocalObject(oNpc, "al_training_partner")))
    {
        return;
    }

    string sTag = GetTag(oNpc);
    string sPartnerTag = "";
    string sAreaPartnerKey = "";
    string sAreaSelfKey = "";

    if (sTag == "FACTION_NPC1")
    {
        sPartnerTag = "FACTION_NPC2";
        sAreaSelfKey = "al_training_npc1";
        sAreaPartnerKey = "al_training_npc2";
    }
    else if (sTag == "FACTION_NPC2")
    {
        sPartnerTag = "FACTION_NPC1";
        sAreaSelfKey = "al_training_npc2";
        sAreaPartnerKey = "al_training_npc1";
    }

    if (sPartnerTag == "")
    {
        return;
    }

    object oArea = GetArea(oNpc);
    object oPartner = OBJECT_INVALID;
    int bResetCache = FALSE;

    if (GetIsObjectValid(oArea))
    {
        if (GetLocalInt(oArea, "al_training_partner_cached"))
        {
            object oCachedSelf = GetLocalObject(oArea, sAreaSelfKey);
            object oCachedPartner = GetLocalObject(oArea, sAreaPartnerKey);
            if (!GetIsObjectValid(oCachedSelf) || !GetIsObjectValid(oCachedPartner))
            {
                SetLocalInt(oArea, "al_training_partner_cached", FALSE);
                DeleteLocalObject(oArea, sAreaSelfKey);
                DeleteLocalObject(oArea, sAreaPartnerKey);
                bResetCache = TRUE;
            }
        }
        SetLocalObject(oArea, sAreaSelfKey, oNpc);
        oPartner = GetLocalObject(oArea, sAreaPartnerKey);
    }

    if (!GetIsObjectValid(oPartner))
    {
        if (!GetIsObjectValid(oArea) || !GetLocalInt(oArea, "al_training_partner_cached"))
        {
            oPartner = GetObjectByTag(sPartnerTag);
            if (GetIsObjectValid(oArea) && GetIsObjectValid(oPartner) && GetArea(oPartner) == oArea)
            {
                SetLocalObject(oArea, sAreaPartnerKey, oPartner);
            }
        }
    }

    if (GetIsObjectValid(oArea) && bResetCache)
    {
        SetLocalInt(oArea, "al_training_partner_cached", TRUE);
    }

    if (GetIsObjectValid(oPartner) && oPartner != oNpc)
    {
        SetLocalObject(oNpc, "al_training_partner", oPartner);
    }
}

void AL_InitBarPair(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetIsObjectValid(GetLocalObject(oNpc, "al_bar_pair")))
    {
        return;
    }

    int nRole = GetLocalInt(oNpc, AL_ROLE_LOCAL);
    string sPartnerTag = "";
    string sAreaPartnerKey = "";
    string sAreaSelfKey = "";

    if (nRole == AL_ROLE_BARTENDER)
    {
        sPartnerTag = "BARMAID";
        sAreaSelfKey = "al_bar_bartender";
        sAreaPartnerKey = "al_bar_barmaid";
    }
    else if (nRole == AL_ROLE_BARMAID)
    {
        sPartnerTag = "BARTENDER";
        sAreaSelfKey = "al_bar_barmaid";
        sAreaPartnerKey = "al_bar_bartender";
    }

    if (sPartnerTag == "")
    {
        return;
    }

    object oArea = GetArea(oNpc);
    object oPartner = OBJECT_INVALID;

    if (GetIsObjectValid(oArea))
    {
        SetLocalObject(oArea, sAreaSelfKey, oNpc);
        oPartner = GetLocalObject(oArea, sAreaPartnerKey);
    }

    if (!GetIsObjectValid(oPartner))
    {
        oPartner = GetObjectByTag(sPartnerTag);
        if (GetIsObjectValid(oArea) && GetIsObjectValid(oPartner) && GetArea(oPartner) == oArea)
        {
            SetLocalObject(oArea, sAreaPartnerKey, oPartner);
        }
        else
        {
            oPartner = OBJECT_INVALID;
        }
    }

    if (GetIsObjectValid(oPartner) && oPartner != oNpc)
    {
        SetLocalObject(oNpc, "al_bar_pair", oPartner);
        if (!GetIsObjectValid(GetLocalObject(oPartner, "al_bar_pair")))
        {
            SetLocalObject(oPartner, "al_bar_pair", oNpc);
        }
    }
}

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "l", -1);
    AL_InitTrainingPartner(oNpc);
    AL_InitBarPair(oNpc);
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

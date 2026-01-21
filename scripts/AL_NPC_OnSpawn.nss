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
    string sAreaPartnerKey = "";
    string sAreaSelfKey = "";
    string sAreaPartnerRefKey = "";

    if (sTag == "FACTION_NPC1")
    {
        sAreaSelfKey = "al_training_npc1";
        sAreaPartnerKey = "al_training_npc2";
        sAreaPartnerRefKey = "al_training_npc2_ref";
    }
    else if (sTag == "FACTION_NPC2")
    {
        sAreaSelfKey = "al_training_npc2";
        sAreaPartnerKey = "al_training_npc1";
        sAreaPartnerRefKey = "al_training_npc1_ref";
    }

    if (sAreaPartnerKey == "")
    {
        return;
    }

    object oArea = GetArea(oNpc);
    object oPartner = OBJECT_INVALID;
    int bResetCache = FALSE;

    if (GetIsObjectValid(oArea))
    {
        // Area locals seeded via toolset/bootstrap:
        // "al_training_npc1_ref" / "al_training_npc2_ref" point to the pair.
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
        if (GetIsObjectValid(oArea))
        {
            object oRefPartner = GetLocalObject(oArea, sAreaPartnerRefKey);
            if (GetIsObjectValid(oRefPartner) && GetArea(oRefPartner) == oArea)
            {
                oPartner = oRefPartner;
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
    string sAreaPartnerKey = "";
    string sAreaSelfKey = "";
    string sAreaPartnerRefKey = "";

    if (nRole == AL_ROLE_BARTENDER)
    {
        sAreaSelfKey = "al_bar_bartender";
        sAreaPartnerKey = "al_bar_barmaid";
        sAreaPartnerRefKey = "al_bar_barmaid_ref";
    }
    else if (nRole == AL_ROLE_BARMAID)
    {
        sAreaSelfKey = "al_bar_barmaid";
        sAreaPartnerKey = "al_bar_bartender";
        sAreaPartnerRefKey = "al_bar_bartender_ref";
    }

    if (sAreaPartnerKey == "")
    {
        return;
    }

    object oArea = GetArea(oNpc);
    object oPartner = OBJECT_INVALID;

    if (GetIsObjectValid(oArea))
    {
        // Area locals seeded via toolset/bootstrap:
        // "al_bar_bartender_ref" / "al_bar_barmaid_ref" point to the pair.
        SetLocalObject(oArea, sAreaSelfKey, oNpc);
        oPartner = GetLocalObject(oArea, sAreaPartnerKey);
    }

    if (!GetIsObjectValid(oPartner))
    {
        if (GetIsObjectValid(oArea))
        {
            object oRefPartner = GetLocalObject(oArea, sAreaPartnerRefKey);
            if (GetIsObjectValid(oRefPartner) && GetArea(oRefPartner) == oArea)
            {
                oPartner = oRefPartner;
                SetLocalObject(oArea, sAreaPartnerKey, oPartner);
            }
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
    AL_CacheRoutesForAllSlots(oNpc);

    AL_RegisterNPC(oNpc);
    AL_StartNPCRegistryTracking(oNpc);

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

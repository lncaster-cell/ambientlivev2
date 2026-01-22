// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

#include "al_constants_inc"
#include "al_npc_acts_inc"
#include "al_npc_reg_inc"

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
    int bResetCache = FALSE;

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

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    object oBartenderRef = GetLocalObject(oArea, "al_bar_bartender_ref");
    object oBarmaidRef = GetLocalObject(oArea, "al_bar_barmaid_ref");
    string sAreaPartnerKey = "";
    string sAreaSelfKey = "";
    object oPartnerRef = OBJECT_INVALID;

    if (oNpc == oBartenderRef)
    {
        sAreaSelfKey = "al_bar_bartender";
        sAreaPartnerKey = "al_bar_barmaid";
        oPartnerRef = oBarmaidRef;
    }
    else if (oNpc == oBarmaidRef)
    {
        sAreaSelfKey = "al_bar_barmaid";
        sAreaPartnerKey = "al_bar_bartender";
        oPartnerRef = oBartenderRef;
    }

    if (sAreaPartnerKey == "")
    {
        return;
    }

    object oPartner = OBJECT_INVALID;

    // Area locals seeded via toolset/bootstrap:
    // "al_bar_bartender_ref" / "al_bar_barmaid_ref" point to the pair.
    object oCachedSelf = GetLocalObject(oArea, sAreaSelfKey);
    object oCachedPartner = GetLocalObject(oArea, sAreaPartnerKey);
    if (!GetIsObjectValid(oCachedSelf)
        || !GetIsObjectValid(oCachedPartner)
        || GetArea(oCachedSelf) != oArea
        || GetArea(oCachedPartner) != oArea)
    {
        DeleteLocalObject(oArea, sAreaSelfKey);
        DeleteLocalObject(oArea, sAreaPartnerKey);
    }

    SetLocalObject(oArea, sAreaSelfKey, oNpc);
    oPartner = GetLocalObject(oArea, sAreaPartnerKey);
    if (GetIsObjectValid(oPartner) && GetArea(oPartner) != oArea)
    {
        DeleteLocalObject(oArea, sAreaPartnerKey);
        oPartner = OBJECT_INVALID;
    }

    if (!GetIsObjectValid(oPartner))
    {
        if (GetIsObjectValid(oPartnerRef) && GetArea(oPartnerRef) == oArea)
        {
            oPartner = oPartnerRef;
            SetLocalObject(oArea, sAreaPartnerKey, oPartner);
        }
    }

    if (GetIsObjectValid(oPartner) && oPartner != oNpc)
    {
        SetLocalObject(oNpc, "al_bar_pair", oPartner);
        SetLocalObject(oPartner, "al_bar_pair", oNpc);
    }
}

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "al_last_slot", -1);
    AL_InitTrainingPartner(oNpc);
    AL_InitBarPair(oNpc);
    AL_CacheRoutesForAllSlots(oNpc);

    AL_RegisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        int iSlotCount = GetLocalInt(oArea, "al_player_count");
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

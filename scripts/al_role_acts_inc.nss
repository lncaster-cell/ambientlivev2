// Role activity helpers: map role IDs to default slot activities.

#include "al_acts_inc"
#include "al_constants_inc"

const string AL_ROLE_LOCAL = "al_role";
const string AL_ROLE_APPLIED_LOCAL = "al_role_applied";

const int AL_ROLE_NONE = 0;
const int AL_ROLE_BARTENDER = 1;
const int AL_ROLE_BARMAID = 2;
const int AL_ROLE_LIGHT_KEEPER = 3;
const int AL_ROLE_SMITH = 4;
const int AL_ROLE_COOK = 5;
const int AL_ROLE_MUSICIAN = 6;
const int AL_ROLE_TRAINER = 7;
const int AL_ROLE_THIEF = 8;
const int AL_ROLE_MERCHANT = 9;
const int AL_ROLE_GUARD = 10;
const int AL_ROLE_CITIZEN = 11;

int AL_GetRoleActivity(int nRole)
{
    switch (nRole)
    {
        case AL_ROLE_BARTENDER: return AL_ACT_NPC_BARTENDER;
        case AL_ROLE_BARMAID: return AL_ACT_NPC_BARMAID;
        case AL_ROLE_LIGHT_KEEPER: return AL_ACT_NPC_LIGHT_KEEPER;
        case AL_ROLE_SMITH: return AL_ACT_NPC_FORGE;
        case AL_ROLE_COOK: return AL_ACT_NPC_COOK;
        case AL_ROLE_MUSICIAN: return AL_ACT_NPC_GUITAR;
        case AL_ROLE_TRAINER: return AL_ACT_NPC_TRAINER_PACE;
        case AL_ROLE_THIEF: return AL_ACT_NPC_THIEF;
        case AL_ROLE_MERCHANT: return AL_ACT_NPC_MERCHANT_MULTI;
        case AL_ROLE_GUARD: return AL_ACT_NPC_STAND_CHAT;
        case AL_ROLE_CITIZEN: return AL_ACT_NPC_ACT_ONE;
    }

    return AL_ACT_NPC_HIDDEN;
}

void AL_SetRoleActivitySlots(object oNpc, int nActivity)
{
    int iSlot = 0;

    while (iSlot <= AL_SLOT_MAX)
    {
        SetLocalInt(oNpc, "a" + IntToString(iSlot), nActivity);
        iSlot++;
    }
}

void AL_ApplyRoleActivities(object oNpc)
{
    if (GetLocalInt(oNpc, AL_ROLE_APPLIED_LOCAL) == 1)
    {
        return;
    }

    int nRole = GetLocalInt(oNpc, AL_ROLE_LOCAL);

    if (nRole <= AL_ROLE_NONE)
    {
        return;
    }

    int nActivity = AL_GetRoleActivity(nRole);

    if (nActivity == AL_ACT_NPC_HIDDEN)
    {
        return;
    }

    AL_SetRoleActivitySlots(oNpc, nActivity);
    SetLocalInt(oNpc, AL_ROLE_APPLIED_LOCAL, 1);
}

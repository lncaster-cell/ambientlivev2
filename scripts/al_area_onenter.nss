// Area OnEnter: attach to the Area OnEnter event in the toolset.

#include "al_constants_inc"
#include "al_area_tick_inc"
#include "al_npc_reg_inc"

void AL_CacheTrainingPartners(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, "al_training_partner_cached"))
    {
        return;
    }

    // Preconfigure training partners via toolset/bootstrap on the area:
    // local object "al_training_npc1_ref" + "al_training_npc2_ref".
    object oNpc1 = GetLocalObject(oArea, "al_training_npc1_ref");
    if (GetIsObjectValid(oNpc1) && GetArea(oNpc1) == oArea)
    {
        SetLocalObject(oArea, "al_training_npc1", oNpc1);
    }

    object oNpc2 = GetLocalObject(oArea, "al_training_npc2_ref");
    if (GetIsObjectValid(oNpc2) && GetArea(oNpc2) == oArea)
    {
        SetLocalObject(oArea, "al_training_npc2", oNpc2);
    }

    SetLocalInt(oArea, "al_training_partner_cached", TRUE);
}

void main()
{
    object oArea = OBJECT_SELF;
    object oEntering = GetEnteringObject();

    if (!GetIsObjectValid(oEntering))
    {
        return;
    }

    if (!GetIsPC(oEntering))
    {
        return;
    }

    DeleteLocalInt(oEntering, "al_exit_counted");

    int iPlayers = GetLocalInt(oArea, "al_player_count") + 1;
    SetLocalInt(oArea, "al_player_count", iPlayers);

    if (iPlayers != 1)
    {
        return;
    }

    int iToken = GetLocalInt(oArea, "al_tick_token") + 1;
    SetLocalInt(oArea, "al_tick_token", iToken);

    SetLocalInt(oArea, "al_slot", AL_ComputeTimeSlot());

    AL_CacheAreaRoutes(oArea);
    AL_CacheTrainingPartners(oArea);
    AL_SyncAreaNPCRegistry(oArea);
    AL_UnhideAndResyncRegisteredNPCs(oArea);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, iToken));
}

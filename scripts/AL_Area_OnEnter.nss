// Area OnEnter: attach to the Area OnEnter event in the toolset.

#include "AL_Constants_Inc"
#include "AL_Area_Tick_Inc"
#include "AL_NPC_Registry_Inc"

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

    int iPlayers = GetLocalInt(oArea, "p") + 1;
    SetLocalInt(oArea, "p", iPlayers);

    if (iPlayers != 1)
    {
        return;
    }

    int iToken = GetLocalInt(oArea, "t") + 1;
    SetLocalInt(oArea, "t", iToken);

    SetLocalInt(oArea, "s", AL_ComputeTimeSlot());

    AL_CacheAreaRoutes(oArea);
    AL_CacheTrainingPartners(oArea);
    AL_SyncAreaNPCRegistry(oArea);
    AL_UnhideAndResyncRegisteredNPCs(oArea);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, iToken));
}

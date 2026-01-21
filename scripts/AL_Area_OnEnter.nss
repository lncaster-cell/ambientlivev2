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

    object oNpc1 = GetObjectByTag("FACTION_NPC1");
    if (GetIsObjectValid(oNpc1) && GetArea(oNpc1) == oArea)
    {
        SetLocalObject(oArea, "al_training_npc1", oNpc1);
    }

    object oNpc2 = GetObjectByTag("FACTION_NPC2");
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

    AL_CacheTrainingPartners(oArea);
    AL_UnhideAndResyncRegisteredNPCs(oArea);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, iToken));
}

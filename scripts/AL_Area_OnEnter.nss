// Area OnEnter: attach to the Area OnEnter event in the toolset.

#include "AL_Constants_Inc"
#include "AL_Area_Tick_Inc"
#include "AL_NPC_Registry_Inc"

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

    AL_UnhideAndResyncRegisteredNPCs(oArea);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, iToken));
}

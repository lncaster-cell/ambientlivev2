// Area OnExit: attach to the Area OnExit event in the toolset.

#include "al_npc_registry_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oExiting = GetExitingObject();

    if (!GetIsObjectValid(oExiting))
    {
        return;
    }

    if (!GetIsPC(oExiting))
    {
        return;
    }

    if (GetLocalInt(oExiting, "al_exit_counted") == 1)
    {
        return;
    }

    SetLocalInt(oExiting, "al_exit_counted", 1);

    int iPlayers = GetLocalInt(oArea, "p") - 1;
    if (iPlayers < 0)
    {
        iPlayers = 0;
    }

    SetLocalInt(oArea, "p", iPlayers);

    if (iPlayers != 0)
    {
        return;
    }

    SetLocalInt(oArea, "t", GetLocalInt(oArea, "t") + 1);
    AL_HideRegisteredNPCs(oArea);
}

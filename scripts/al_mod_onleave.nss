// Module OnClientLeave: attach to the Module OnClientLeave event in the toolset.

#include "al_npc_reg_inc"

void main()
{
    object oLeaving = GetExitingObject();

    if (!GetIsObjectValid(oLeaving))
    {
        return;
    }

    if (!GetIsPC(oLeaving))
    {
        return;
    }

    if (GetLocalInt(oLeaving, "al_exit_counted") == 1)
    {
        return;
    }

    object oArea = GetArea(oLeaving);

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oLeaving, "al_exit_counted", 1);

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

// Module OnClientLeave: attach to the Module OnClientLeave event in the toolset.

#include "AL_NPC_Registry_Inc"

void main()
{
    object oLeaving = GetLeavingObject();

    if (!GetIsObjectValid(oLeaving))
    {
        return;
    }

    if (!GetIsPC(oLeaving))
    {
        return;
    }

    object oArea = GetArea(oLeaving);

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

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

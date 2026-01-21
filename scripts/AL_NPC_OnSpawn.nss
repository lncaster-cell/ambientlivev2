// NPC OnSpawn: attach to NPC OnSpawn in the toolset.

void AL_RegisterNPC(object oNpc)
{
    object oArea = GetArea(oNpc);

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int iIndex = 0;
    while (iIndex < 100)
    {
        if (GetLocalObject(oArea, "n" + IntToString(iIndex)) == oNpc)
        {
            return;
        }
        iIndex++;
    }

    int iCount = GetLocalInt(oArea, "n");

    if (iCount >= 100)
    {
        return;
    }

    SetLocalObject(oArea, "n" + IntToString(iCount), oNpc);
    SetLocalInt(oArea, "n", iCount + 1);
}

void main()
{
    object oNpc = OBJECT_SELF;
    SetLocalInt(oNpc, "l", -1);

    AL_RegisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        int iSlotCount = GetLocalInt(oArea, "p");
        if (iSlotCount > 0)
        {
            if (GetScriptHidden(oNpc))
            {
                SetScriptHidden(oNpc, FALSE, TRUE);
            }
            SignalEvent(oNpc, EventUserDefined(3006));
        }
        else
        {
            SetScriptHidden(oNpc, TRUE, TRUE);
        }
    }
}

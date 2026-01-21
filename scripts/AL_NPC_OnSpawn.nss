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
    AL_RegisterNPC(OBJECT_SELF);
}

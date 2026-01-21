// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

void main()
{
    object oNpc = OBJECT_SELF;
    int nEvent = GetUserDefinedEventNumber();
    int nSlot = -1;

    if (nEvent == 3006)
    {
        object oArea = GetArea(oNpc);
        if (GetIsObjectValid(oArea))
        {
            nSlot = GetLocalInt(oArea, "s");
        }
    }
    else if (nEvent >= 3000 && nEvent <= 3005)
    {
        nSlot = nEvent - 3000;
    }
    else
    {
        return;
    }

    if (nSlot < 0 || nSlot > 5)
    {
        return;
    }

    if (GetLocalInt(oNpc, "l") == nSlot)
    {
        return;
    }

    SetLocalInt(oNpc, "l", nSlot);
}

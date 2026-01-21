// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

void main()
{
    int nEvent = GetUserDefinedEventNumber();
    int iSlot = -1;

    if (nEvent == 3006)
    {
        object oArea = GetArea(OBJECT_SELF);

        if (GetIsObjectValid(oArea))
        {
            iSlot = GetLocalInt(oArea, "s");
        }
    }
    else if (nEvent >= 3000 && nEvent <= 3005)
    {
        iSlot = nEvent - 3000;
    }
    else
    {
        return;
    }

    if (iSlot < 0 || iSlot > 5)
    {
        return;
    }

    if (GetLocalInt(OBJECT_SELF, "l") == iSlot)
    {
        return;
    }

    SetLocalInt(OBJECT_SELF, "l", iSlot);
}

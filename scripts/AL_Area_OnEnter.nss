// Area OnEnter: attach to the Area OnEnter event in the toolset.

const int AL_EVT_RESYNC = 3006;

void AL_ResyncRegisteredNPCs(object oArea)
{
    int iCount = GetLocalInt(oArea, "n");
    int i = 0;

    while (i < iCount)
    {
        string sKey = "n" + IntToString(i);
        object oNpc = GetLocalObject(oArea, sKey);

        if (!GetIsObjectValid(oNpc))
        {
            int iLastIndex = iCount - 1;

            if (i != iLastIndex)
            {
                object oSwap = GetLocalObject(oArea, "n" + IntToString(iLastIndex));
                SetLocalObject(oArea, sKey, oSwap);
            }

            DeleteLocalObject(oArea, "n" + IntToString(iLastIndex));
            iCount--;
            SetLocalInt(oArea, "n", iCount);
            continue;
        }

        SetScriptHidden(oNpc, FALSE);
        SignalEvent(oNpc, EventUserDefined(AL_EVT_RESYNC));
        i++;
    }
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

    int iPlayers = GetLocalInt(oArea, "p") + 1;
    SetLocalInt(oArea, "p", iPlayers);

    if (iPlayers != 1)
    {
        return;
    }

    int iToken = GetLocalInt(oArea, "t") + 1;
    SetLocalInt(oArea, "t", iToken);

    int iSlot = GetTimeHour() / 4;
    if (iSlot < 0)
    {
        iSlot = 0;
    }
    else if (iSlot > 5)
    {
        iSlot = 5;
    }

    SetLocalInt(oArea, "s", iSlot);

    AL_ResyncRegisteredNPCs(oArea);
    ExecuteScript("AL_Area_Tick", oArea);
}

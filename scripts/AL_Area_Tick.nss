// Shared Area tick helper: scheduled every 45s while players are present.

int AL_GetTimeSlot()
{
    int iSlot = GetTimeHour() / 4;

    if (iSlot < 0)
    {
        iSlot = 0;
    }
    else if (iSlot > 5)
    {
        iSlot = 5;
    }

    return iSlot;
}

void AL_BroadcastSlot(object oArea, int nEvent)
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

                if (GetIsObjectValid(oSwap))
                {
                    SetLocalInt(oSwap, "l", i);
                }
            }

            DeleteLocalObject(oArea, "n" + IntToString(iLastIndex));
            iCount--;
            SetLocalInt(oArea, "n", iCount);
            continue;
        }

        SignalEvent(oNpc, EventUserDefined(nEvent));
        i++;
    }
}

void main()
{
    object oArea = OBJECT_SELF;
    int iToken = GetLocalInt(oArea, "t0");

    if (GetLocalInt(oArea, "p") <= 0)
    {
        return;
    }

    if (iToken != GetLocalInt(oArea, "t"))
    {
        return;
    }

    int iSlot = AL_GetTimeSlot();
    int iStoredSlot = GetLocalInt(oArea, "s");

    if (iSlot != iStoredSlot)
    {
        SetLocalInt(oArea, "s", iSlot);
        AL_BroadcastSlot(oArea, 3000 + iSlot);
    }

    SetLocalInt(oArea, "t0", iToken);
    DelayCommand(45.0, ExecuteScript("AL_Area_Tick", oArea));
}

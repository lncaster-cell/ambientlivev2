// Shared Area tick helper: scheduled every 45s while players are present.

const float AL_TICK_PERIOD = 45.0;

void AL_BroadcastSlot(object oArea, int nSlot)
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

        SignalEvent(oNpc, EventUserDefined(3000 + nSlot));
        i++;
    }
}

void AreaTick(object oArea, int nToken)
{
    if (GetLocalInt(oArea, "p") <= 0)
    {
        return;
    }

    if (nToken != GetLocalInt(oArea, "t"))
    {
        return;
    }

    int iSlot = GetTimeHour() / 4;
    if (iSlot < 0)
    {
        iSlot = 0;
    }
    else if (iSlot > 5)
    {
        iSlot = 5;
    }

    if (iSlot == GetLocalInt(oArea, "s"))
    {
        DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
        return;
    }

    SetLocalInt(oArea, "s", iSlot);
    AL_BroadcastSlot(oArea, iSlot);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
}

void main()
{
    object oArea = OBJECT_SELF;
    AreaTick(oArea, GetLocalInt(oArea, "t"));
}

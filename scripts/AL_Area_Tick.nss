// Shared Area tick helper: scheduled every 45s while players are present.

const int AL_EVENT_AREA_ENTER = 3000;
const int AL_EVENT_AREA_EXIT = 3001;
const int AL_EVENT_TICK = 3002;
const int AL_EVENT_REGISTER = 3003;
const int AL_EVENT_UNREGISTER = 3004;
const int AL_EVENT_RESET = 3005;
const int AL_EVENT_DEBUG = 3006;

void AL_SignalRegisteredNPCs(object oArea, int nEvent)
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

        SignalEvent(oNpc, EventUserDefined(nEvent));
        i++;
    }
}

void main()
{
    object oArea = OBJECT_SELF;

    if (GetLocalInt(oArea, "p") <= 0)
    {
        SetLocalInt(oArea, "t", 0);
        return;
    }

    int iTickCount = GetLocalInt(oArea, "s") + 1;
    SetLocalInt(oArea, "s", iTickCount);

    AL_SignalRegisteredNPCs(oArea, AL_EVENT_TICK);

    SetLocalInt(oArea, "t", 1);
    DelayCommand(45.0, ExecuteScript("AL_Area_Tick", oArea));
}

// NPC OnUserDefined: attach to NPC OnUserDefined in the toolset.

const int AL_EVENT_AREA_ENTER = 3000;
const int AL_EVENT_AREA_EXIT = 3001;
const int AL_EVENT_TICK = 3002;
const int AL_EVENT_REGISTER = 3003;
const int AL_EVENT_UNREGISTER = 3004;
const int AL_EVENT_RESET = 3005;
const int AL_EVENT_DEBUG = 3006;

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

void AL_UnregisterNPC(object oNpc)
{
    object oArea = GetArea(oNpc);

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int iCount = GetLocalInt(oArea, "n");

    if (iCount <= 0)
    {
        return;
    }

    int iIndex = 0;
    int bFound = FALSE;
    while (iIndex < iCount)
    {
        string sKey = "n" + IntToString(iIndex);
        if (GetLocalObject(oArea, sKey) == oNpc)
        {
            bFound = TRUE;
            break;
        }
        iIndex++;
    }

    if (!bFound)
    {
        return;
    }

    string sKey = "n" + IntToString(iIndex);

    int iLastIndex = iCount - 1;

    if (iIndex != iLastIndex)
    {
        object oSwap = GetLocalObject(oArea, "n" + IntToString(iLastIndex));
        SetLocalObject(oArea, sKey, oSwap);
    }

    DeleteLocalObject(oArea, "n" + IntToString(iLastIndex));
    SetLocalInt(oArea, "n", iLastIndex);
}

void main()
{
    int nEvent = GetUserDefinedEventNumber();

    switch (nEvent)
    {
        case AL_EVENT_AREA_ENTER:
            break;
        case AL_EVENT_AREA_EXIT:
            break;
        case AL_EVENT_TICK:
            break;
        case AL_EVENT_REGISTER:
            AL_RegisterNPC(OBJECT_SELF);
            break;
        case AL_EVENT_UNREGISTER:
            AL_UnregisterNPC(OBJECT_SELF);
            break;
        case AL_EVENT_RESET:
            break;
        case AL_EVENT_DEBUG:
            break;
        default:
            break;
    }
}

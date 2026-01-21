// Area OnExit: attach to the Area OnExit event in the toolset.

void AL_HideRegisteredNPCs(object oArea)
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

        SetScriptHidden(oNpc, TRUE, TRUE);
        i++;
    }
}

void main()
{
    object oArea = OBJECT_SELF;
    object oExiting = GetExitingObject();

    if (!GetIsObjectValid(oExiting))
    {
        return;
    }

    if (!GetIsPC(oExiting))
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

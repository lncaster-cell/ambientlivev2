#include "AL_Area_Tick_Inc"

void main()
{
    object oArea = OBJECT_SELF;
    AreaTick(oArea, GetLocalInt(oArea, "t"));
}

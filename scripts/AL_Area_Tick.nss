#include "al_area_tick_inc"

void main()
{
    object oArea = OBJECT_SELF;
    AreaTick(oArea, GetLocalInt(oArea, "t"));
}

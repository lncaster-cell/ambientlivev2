// Activity IDs and metadata helpers for Ambient Life V2.
// This file provides static mappings for activity IDs to animation lists and
// optional waypoint/tag requirements. It is data only and does not perform
// any runtime tag searches.

const int AL_ACT_NPC_HIDDEN = 0;
const int AL_ACT_NPC_ACT_ONE = 1;
const int AL_ACT_NPC_ACT_TWO = 2;
const int AL_ACT_NPC_DINNER = 3;
const int AL_ACT_NPC_MIDNIGHT_BED = 4;
const int AL_ACT_NPC_SLEEP_BED = 5;
const int AL_ACT_NPC_WAKE = 6;
const int AL_ACT_NPC_AGREE = 7;
const int AL_ACT_NPC_ANGRY = 8;
const int AL_ACT_NPC_SAD = 9;
const int AL_ACT_NPC_COOK = 10;
const int AL_ACT_NPC_DANCE_FEMALE = 11;
const int AL_ACT_NPC_DANCE_MALE = 12;
const int AL_ACT_NPC_DRUM = 13;
const int AL_ACT_NPC_FLUTE = 14;
const int AL_ACT_NPC_FORGE = 15;
const int AL_ACT_NPC_GUITAR = 16;
const int AL_ACT_NPC_WOODSMAN = 17;
const int AL_ACT_NPC_MEDITATE = 18;
const int AL_ACT_NPC_POST = 19;
const int AL_ACT_NPC_READ = 20;
const int AL_ACT_NPC_SIT = 21;
const int AL_ACT_NPC_SIT_DINNER = 22;
const int AL_ACT_NPC_STAND_CHAT = 23;
const int AL_ACT_NPC_TRAINING_ONE = 24;
const int AL_ACT_NPC_TRAINING_TWO = 25;
const int AL_ACT_NPC_TRAINER_PACE = 26;
const int AL_ACT_NPC_WWP = 27;
const int AL_ACT_NPC_CHEER = 28;
const int AL_ACT_NPC_COOK_MULTI = 29;
const int AL_ACT_NPC_FORGE_MULTI = 30;
const int AL_ACT_NPC_MIDNIGHT_90 = 31;
const int AL_ACT_NPC_SLEEP_90 = 32;
const int AL_ACT_NPC_THIEF = 33;
const int AL_ACT_NPC_HIDE = 34;
const int AL_ACT_NPC_SEEK = 35;
const int AL_ACT_NPC_THIEF2 = 36;
const int AL_ACT_NPC_ASSASSIN = 37;
const int AL_ACT_NPC_MERCHANT_MULTI = 38;
const int AL_ACT_NPC_KNEEL_TALK = 39;
const int AL_ACT_NPC_LIGHT_KEEPER = 40;
const int AL_ACT_NPC_BARMAID = 41;
const int AL_ACT_NPC_BARTENDER = 42;
const int AL_ACT_NPC_GUARD = 43;
const int AL_ACT_LOCATE_WRAPPER_MIN = 91;
const int AL_ACT_LOCATE_WRAPPER_MAX = 98;
const int AL_ACT_RESERVED = 200;

// Helper animation names used by shared helpers.
const string AL_HELPER_ANIM_SITUP = "situp";
const string AL_HELPER_ANIM_IDLE = "idle";

int AL_IsLocateWrapperActivity(int nActivity)
{
    return nActivity >= AL_ACT_LOCATE_WRAPPER_MIN && nActivity <= AL_ACT_LOCATE_WRAPPER_MAX;
}

string AL_GetLocateWrapperCustomAnims(int nActivity)
{
    switch (nActivity)
    {
        case 91: return "lookleft, lookright, shrug";
        case 92: return "bored, scratchhead, yawn";
        case 93: return "sitfidget, sitidle, sittalk, sittalk01, sittalk02";
        case 94: return "kneelidle, kneeltalk";
        case 95: return "chuckle, nodno, nodyes, talk01, talk02, talklaugh";
        case 96: return "craft01, dustoff, forge01, openlock";
        case 97: return "meditate";
        case 98: return "disableground, sleightofhand, sneak";
    }

    return "";
}

string AL_GetLocateWrapperNumericAnims(int nActivity)
{
    return "";
}

string AL_GetActivityCustomAnims(int nActivity)
{
    switch (nActivity)
    {
        case AL_ACT_NPC_ACT_ONE: return "lookleft, lookright";
        case AL_ACT_NPC_ACT_TWO: return "lookleft, lookright";
        case AL_ACT_NPC_DINNER: return "sitdrink, siteat, sitidle";
        case AL_ACT_NPC_MIDNIGHT_BED: return "laydownB, proneB";
        case AL_ACT_NPC_SLEEP_BED: return "laydownB, proneB";
        case AL_ACT_NPC_WAKE: return "sitdrink, siteat, sitidle";
        case AL_ACT_NPC_AGREE: return "chuckle, flirt, nodyes";
        case AL_ACT_NPC_ANGRY: return "intimidate, nodno, talkshout";
        case AL_ACT_NPC_SAD: return "talksad, tired";
        case AL_ACT_NPC_COOK: return "cooking02, disablefront";
        case AL_ACT_NPC_DANCE_FEMALE: return "curtsey, dance01";
        case AL_ACT_NPC_DANCE_MALE: return "bow, dance01, dance02";
        case AL_ACT_NPC_DRUM: return "bow, playdrum";
        case AL_ACT_NPC_FLUTE: return "curtsey, playflute";
        case AL_ACT_NPC_FORGE: return "craft01, dustoff, forge01";
        case AL_ACT_NPC_GUITAR: return "bow, playguitar";
        case AL_ACT_NPC_WOODSMAN: return "*1attack01, kneelidle";
        case AL_ACT_NPC_MEDITATE: return "meditate";
        case AL_ACT_NPC_POST: return "lookleft, lookright";
        case AL_ACT_NPC_READ: return "sitidle, sitread, sitteat";
        case AL_ACT_NPC_SIT: return "sitfidget, sitidle, sittalk, sittalk01, sittalk02";
        case AL_ACT_NPC_SIT_DINNER:
            return "sitdrink, siteat, sitidle, sittalk, sittalk01, sittalk02";
        case AL_ACT_NPC_STAND_CHAT:
            return "chuckle, lookleft, lookright, shrug, talk01, talk02, talklaugh";
        case AL_ACT_NPC_WWP: return "kneelidle, lookleft, lookright";
        case AL_ACT_NPC_CHEER: return "chuckle, clapping, talklaugh, victory";
        case AL_ACT_NPC_COOK_MULTI:
            return "cooking01, cooking02, craft01, disablefront, dustoff, forge01, gettable, kneelidle, kneelup, openlock, scratchhead";
        case AL_ACT_NPC_FORGE_MULTI:
            return "craft01, dustoff, forge01, forge02, gettable, kneeldown, kneelidle, kneelup, openlock";
        case AL_ACT_NPC_MIDNIGHT_90: return "laydownB, proneB";
        case AL_ACT_NPC_SLEEP_90: return "laydownB, proneB";
        case AL_ACT_NPC_THIEF: return "chuckle, getground, gettable, openlock";
        case AL_ACT_NPC_THIEF2: return "disableground, sleightofhand, sneak";
        case AL_ACT_NPC_ASSASSIN: return "sneak";
        case AL_ACT_NPC_MERCHANT_MULTI:
            return "bored, getground, gettable, openlock, sleightofhand, yawn";
        case AL_ACT_NPC_KNEEL_TALK: return "kneelidle, kneeltalk";
        case AL_ACT_NPC_BARTENDER: return "gettable, lookright, openlock, yawn";
        case AL_ACT_NPC_GUARD: return "bored, lookleft, lookright, sigh";
    }

    return "";
}

string AL_GetActivityNumericAnims(int nActivity)
{
    switch (nActivity)
    {
        case AL_ACT_NPC_ANGRY: return "10";
        case AL_ACT_NPC_SAD: return "9";
        case AL_ACT_NPC_COOK: return "35, 36";
        case AL_ACT_NPC_DANCE_FEMALE: return "27";
    }

    return "";
}

// Base waypoint tag requirements for pacing or WWP activities.
string AL_GetActivityWaypointTag(int nActivity)
{
    switch (nActivity)
    {
        case AL_ACT_NPC_TRAINER_PACE: return "AL_WP_PACE";
        case AL_ACT_NPC_WWP: return "AL_WP_WWP";
    }

    return "";
}

// Training activities require partner NPCs in FACTION_NPC1 / FACTION_NPC2.
int AL_ActivityRequiresTrainingPartner(int nActivity)
{
    if (nActivity == AL_ACT_NPC_TRAINING_ONE || nActivity == AL_ACT_NPC_TRAINING_TWO)
    {
        return TRUE;
    }

    return FALSE;
}

// Barmaid requires Bartender to run in parallel.
int AL_ActivityRequiresBarPair(int nActivity)
{
    return nActivity == AL_ACT_NPC_BARMAID;
}

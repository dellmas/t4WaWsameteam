#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
    if (isDefined(level.st_pair_started)) return;
    level.st_pair_started = true;
    level thread st_pair_enforcer();
}

st_pair_enforcer()
{
    level endon("end_game");

    for (;;)
    {
        wait 1.0;

        p1 = st_get_player("dellmas");
        p2 = st_get_player("Mragentman");

        if (!isDefined(p1) || !isDefined(p2))
            continue;

        t1 = st_get_team(p1);
        t2 = st_get_team(p2);

        // need at least one real team
        if (!st_is_real_team(t1) && !st_is_real_team(t2))
            continue;

        // already together
        if (st_is_real_team(t1) && t1 == t2)
            continue;

        // choose anchor (player already on a team). If both are, prefer Mragentman.
        if (st_is_real_team(t2))
        {
            anchor = p2; follower = p1;
        }
        else if (st_is_real_team(t1))
        {
            anchor = p1; follower = p2;
        }
        else
        {
            continue;
        }

        targetTeam = st_get_team(anchor);
        if (!st_is_real_team(targetTeam))
            continue;

        // debounce: do not spam swaps
        if (isDefined(follower.st_last_swap) && (gettime() - follower.st_last_swap) < 3000)
            continue;

        // Ask the UI to place the follower on the target team.
        // WaW team menu names vary; try both common ones.
        follower notify("menuresponse", "team_marinesopfor", targetTeam);
        follower notify("menuresponse", "team_alliesaxis", targetTeam);

        follower.st_last_swap = gettime();
    }
}

st_get_player(n)
{
    for (i = 0; i < level.players.size; i++)
    {
        p = level.players[i];
        if (isDefined(p) && p.name == n)
            return p;
    }
    return undefined;
}

st_get_team(p)
{
    if (!isDefined(p) || !isDefined(p.pers) || !isDefined(p.pers["team"]))
        return "none";
    return p.pers["team"];
}

st_is_real_team(t)
{
    return (t == "allies" || t == "axis");
}

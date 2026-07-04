/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.formation;

// import uim.platform.appevents.domain.entities.formation;
// import uim.platform.appevents.presentation.cli.models.formation;
// import std.stdio  : writeln, writefln;
// import std.conv   : to;
// import std.string : replicate;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:


class CliFormationView {
    void renderList(CliFormationModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Formations ===");
        writefln("%-38s %-32s %-12s", "ID", "Name", "Status");
        writeln("-".replicate(86));
        foreach (i; model.items)
            writefln("%-38s %-32s %-12s", i.id.value, i.name, i.status.to!string);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(Formation i) {
        writeln("=== Formation Detail ===");
        writefln("  ID               : %s", i.id.value);
        writefln("  Name             : %s", i.name);
        writefln("  Description      : %s", i.description);
        writefln("  Global Account   : %s", i.globalAccountId);
        writefln("  Status           : %s", i.status.to!string);
        writefln("  System Count     : %d", i.systemCount);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

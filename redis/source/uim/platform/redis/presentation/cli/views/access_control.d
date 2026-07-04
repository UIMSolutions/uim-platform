/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.access_control;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;

mixin(ShowModule!());

@safe:

class CliAccessControlView {
    void renderList(CliAccessControlModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Access Control Rules ===");
        writefln("%-38s %-20s %-10s %-8s %-5s", "ID", "CIDR", "Direction", "Action", "Prio");
        writeln("-".replicate(83));
        foreach (a; model.rules)
            writefln("%-38s %-20s %-10s %-8s %-5s",
                a.id.value, a.cidrBlock, a.direction, a.action, a.priority.to!string);
        writefln("Total: %d", model.rules.length);
    }

    void renderDetail(AccessControl a) {
        writeln("=== Access Control Detail ===");
        writefln("  ID         : %s", a.id.value);
        writefln("  CIDR Block : %s", a.cidrBlock);
        writefln("  Direction  : %s", a.direction);
        writefln("  Action     : %s", a.action);
        writefln("  Priority   : %d", a.priority);
        writefln("  Instance   : %s", a.instanceId.value);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

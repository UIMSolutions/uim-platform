/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.service_plan;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliServicePlanView {
    void renderList(CliServicePlanModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Service Plans ===");
        writefln("%-38s %-20s %-10s %-10s %-6s", "ID", "Name", "Tier", "Memory", "Avail");
        writeln("-".replicate(86));
        foreach (p; model.plans)
            writefln("%-38s %-20s %-10s %-10s %-6s",
                p.id.value, p.name, p.tier.to!string, p.memoryMb.to!string ~ "MB",
                p.available ? "yes" : "no");
        writefln("Total: %d", model.plans.length);
    }

    void renderDetail(ServicePlan p) {
        writeln("=== Service Plan Detail ===");
        writefln("  ID               : %s", p.id.value);
        writefln("  Name             : %s", p.name);
        writefln("  Tier             : %s", p.tier.to!string);
        writefln("  Memory MB        : %d", p.memoryMb);
        writefln("  Max Connections  : %d", p.maxConnections);
        writefln("  HA Enabled       : %s", p.haEnabled ? "yes" : "no");
        writefln("  Persistence      : %s", p.persistenceEnabled ? "yes" : "no");
        writefln("  TLS              : %s", p.tlsEnabled ? "yes" : "no");
        writefln("  Available        : %s", p.available ? "yes" : "no");
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

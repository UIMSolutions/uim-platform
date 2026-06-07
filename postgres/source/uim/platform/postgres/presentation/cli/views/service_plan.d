/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.service_plan;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;

// mixin(ShowModule!());

@safe:

class CliServicePlanView {
    void renderList(CliServicePlanModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Service Plans ===");
        writefln("%-38s %-24s %-10s %-8s %-8s", "ID", "Name", "Tier", "MemGB", "StrgGB");
        writeln("-".replicate(90));
        foreach (p; model.plans)
            writefln("%-38s %-24s %-10s %-8s %-8s",
                p.id.value, p.name, p.tier.to!string, p.memoryGb.to!string, p.storageGb.to!string);
        writefln("Total: %d", model.plans.length);
    }

    void renderDetail(ServicePlan p) {
        writeln("=== Service Plan Detail ===");
        writefln("  ID              : %s", p.id.value);
        writefln("  Name            : %s", p.name);
        writefln("  Tier            : %s", p.tier.to!string);
        writefln("  Memory GB       : %d", p.memoryGb);
        writefln("  Storage GB      : %d", p.storageGb);
        writefln("  Max Connections : %d", p.maxConnections);
        writefln("  Multi-AZ        : %s", p.multiAzSupported ? "yes" : "no");
        writefln("  Available       : %s", p.available ? "yes" : "no");
        writefln("  Pricing Unit    : %s", p.pricingUnit);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

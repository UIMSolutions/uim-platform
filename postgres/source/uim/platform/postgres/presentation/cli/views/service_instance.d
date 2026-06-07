/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.service_instance;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;

// mixin(ShowModule!());

@safe:

class CliServiceInstanceView {
    void renderList(CliServiceInstanceModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Service Instances ===");
        writefln("%-38s %-24s %-12s %-8s %-6s", "ID", "Name", "Status", "MemGB", "HA");
        writeln("-".replicate(92));
        foreach (i; model.instances)
            writefln("%-38s %-24s %-12s %-8s %-6s",
                i.id.value, i.name, i.status.to!string, i.memoryGb.to!string, i.multiAz ? "yes" : "no");
        writefln("Total: %d", model.instances.length);
    }

    void renderDetail(ServiceInstance i) {
        writeln("=== Service Instance Detail ===");
        writefln("  ID            : %s", i.id.value);
        writefln("  Name          : %s", i.name);
        writefln("  Status        : %s", i.status.to!string);
        writefln("  Hyperscaler   : %s", i.hyperscaler.to!string);
        writefln("  Region        : %s", i.region);
        writefln("  Engine        : %s", i.engineVersion.to!string);
        writefln("  Memory GB     : %d", i.memoryGb);
        writefln("  Storage GB    : %d", i.storageGb);
        writefln("  Host          : %s", i.host);
        writefln("  Port          : %d", i.port);
        writefln("  DB Name       : %s", i.dbName);
        writefln("  SSL           : %s", i.sslEnabled ? "yes" : "no");
        writefln("  Multi-AZ      : %s", i.multiAz ? "yes" : "no");
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

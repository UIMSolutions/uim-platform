/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.service_instance;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;

// mixin(ShowModule!());

@safe:

/// CLI View — renders ServiceInstance data as formatted terminal output.
class CliServiceInstanceView {
    void renderList(CliServiceInstanceModel model) {
        if (model.errorMessage.length > 0) {
            writefln("ERROR: %s", model.errorMessage);
            return;
        }
        writeln("=== Service Instances ===");
        writefln("%-38s %-24s %-12s %-8s %-8s", "ID", "Name", "Status", "Memory", "HA");
        writeln("-".replicate(94));
        foreach (i; model.instances) {
            writefln("%-38s %-24s %-12s %-8s %-8s",
                i.id.value, i.name, i.status.to!string,
                i.memoryMb.to!string ~ "MB", i.haEnabled ? "yes" : "no");
        }
        writefln("Total: %d", model.instances.length);
    }

    void renderDetail(ServiceInstance i) {
        writeln("=== Service Instance Detail ===");
        writefln("  ID             : %s", i.id.value);
        writefln("  Name           : %s", i.name);
        writefln("  Status         : %s", i.status.to!string);
        writefln("  Hyperscaler    : %s", i.hyperscaler.to!string);
        writefln("  Region         : %s", i.region);
        writefln("  Redis Version  : %s", i.redisVersion.to!string);
        writefln("  Memory MB      : %d", i.memoryMb);
        writefln("  Max Connections: %d", i.maxConnections);
        writefln("  TLS Enabled    : %s", i.tlsEnabled ? "yes" : "no");
        writefln("  HA Enabled     : %s", i.haEnabled ? "yes" : "no");
        writefln("  Persistence    : %s", i.persistenceMode.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

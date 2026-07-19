/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.configuration;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliConfigurationView {
    void renderList(CliConfigurationModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Configurations ===");
        writefln("%-38s %-20s %-18s", "ID", "Instance", "Eviction Policy");
        writeln("-".replicate(80));
        foreach (c; model.configurations)
            writefln("%-38s %-20s %-18s",
                c.id.value, c.instanceId.value[0..min(20, c.instanceId.value.length)],
                c.maxMemoryPolicy.to!string);
        writefln("Total: %d", model.configurations.length);
    }

    void renderDetail(Configuration c) {
        writeln("=== Configuration Detail ===");
        writefln("  ID                    : %s", c.id.value);
        writefln("  Instance ID           : %s", c.instanceId.value);
        writefln("  Max Memory Policy     : %s", c.maxMemoryPolicy.to!string);
        writefln("  Timeout               : %d", c.timeout_);
        writefln("  Max Connections       : %d", c.maxConnections);
        writefln("  TLS Enabled           : %s", c.tlsEnabled ? "yes" : "no");
        writefln("  Persistence Mode      : %s", c.persistenceMode.to!string);
        writefln("  Keyspace Notifications: %s", c.notifyKeyspaceEvents ? "yes" : "no");
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

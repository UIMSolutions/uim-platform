/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.service_binding;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;

// mixin(ShowModule!());

@safe:

class CliServiceBindingView {
    void renderList(CliServiceBindingModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Service Bindings ===");
        writefln("%-38s %-24s %-12s", "ID", "Name", "Status");
        writeln("-".replicate(76));
        foreach (b; model.bindings)
            writefln("%-38s %-24s %-12s", b.id.value, b.name, b.status.to!string);
        writefln("Total: %d", model.bindings.length);
    }

    void renderDetail(ServiceBinding b) {
        writeln("=== Service Binding Detail ===");
        writefln("  ID            : %s", b.id.value);
        writefln("  Name          : %s", b.name);
        writefln("  Status        : %s", b.status.to!string);
        writefln("  Instance ID   : %s", b.instanceId.value);
        writefln("  App ID        : %s", b.appId);
        writefln("  Host          : %s", b.bindingHost);
        writefln("  Port          : %d", b.bindingPort);
        writefln("  Database      : %s", b.database);
        writefln("  SSL Mode      : %s", b.sslMode.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

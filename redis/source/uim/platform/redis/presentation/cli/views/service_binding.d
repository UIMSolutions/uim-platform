/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.service_binding;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;

mixin(ShowModule!());

@safe:

class CliServiceBindingView {
    void renderList(CliServiceBindingModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Service Bindings ===");
        writefln("%-38s %-24s %-14s %-12s", "ID", "Name", "Instance", "Status");
        writeln("-".replicate(90));
        foreach (b; model.bindings)
            writefln("%-38s %-24s %-14s %-12s",
                b.id.value, b.name, b.instanceId.value[0..min(14, b.instanceId.value.length)], b.status.to!string);
        writefln("Total: %d", model.bindings.length);
    }

    void renderDetail(ServiceBinding b) {
        writeln("=== Service Binding Detail ===");
        writefln("  ID         : %s", b.id.value);
        writefln("  Name       : %s", b.name);
        writefln("  Instance   : %s", b.instanceId.value);
        writefln("  App ID     : %s", b.appId);
        writefln("  Status     : %s", b.status.to!string);
        writefln("  TLS        : %s", b.tls ? "yes" : "no");
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

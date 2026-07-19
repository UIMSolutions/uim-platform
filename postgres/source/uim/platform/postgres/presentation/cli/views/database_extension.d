/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.database_extension;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliDatabaseExtensionView {
    void renderList(CliDatabaseExtensionModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Database Extensions ===");
        writefln("%-38s %-24s %-16s %-12s", "ID", "Extension", "Version", "Status");
        writeln("-".replicate(92));
        foreach (e; model.extensions)
            writefln("%-38s %-24s %-16s %-12s", e.id.value, e.extensionName, e.extensionVersion, e.status.to!string);
        writefln("Total: %d", model.extensions.length);
    }

    void renderDetail(DatabaseExtension e) {
        writeln("=== Database Extension Detail ===");
        writefln("  ID          : %s", e.id.value);
        writefln("  Instance ID : %s", e.instanceId.value);
        writefln("  Name        : %s", e.extensionName);
        writefln("  Version     : %s", e.extensionVersion);
        writefln("  Schema      : %s", e.schema_);
        writefln("  Status      : %s", e.status.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

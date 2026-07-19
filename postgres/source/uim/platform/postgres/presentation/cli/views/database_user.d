/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.database_user;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliDatabaseUserView {
    void renderList(CliDatabaseUserModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Database Users ===");
        writefln("%-38s %-24s %-12s %-12s", "ID", "Username", "Status", "Roles");
        writeln("-".replicate(88));
        foreach (u; model.users)
            writefln("%-38s %-24s %-12s %-12s", u.id.value, u.username, u.status.to!string, u.roles);
        writefln("Total: %d", model.users.length);
    }

    void renderDetail(DatabaseUser u) {
        writeln("=== Database User Detail ===");
        writefln("  ID          : %s", u.id.value);
        writefln("  Instance ID : %s", u.instanceId.value);
        writefln("  Username    : %s", u.username);
        writefln("  Roles       : %s", u.roles);
        writefln("  Status      : %s", u.status.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

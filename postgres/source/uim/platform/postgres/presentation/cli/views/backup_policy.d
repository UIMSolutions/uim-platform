/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.backup_policy;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;

mixin(ShowModule!());

@safe:

class CliBackupPolicyView {
    void renderList(CliBackupPolicyModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Backup Policies ===");
        writefln("%-38s %-38s %-12s", "ID", "Instance ID", "Status");
        writeln("-".replicate(90));
        foreach (p; model.policies)
            writefln("%-38s %-38s %-12s", p.id.value, p.instanceId.value, p.status.to!string);
        writefln("Total: %d", model.policies.length);
    }

    void renderDetail(BackupPolicy p) {
        writeln("=== Backup Policy Detail ===");
        writefln("  ID                : %s", p.id.value);
        writefln("  Instance ID       : %s", p.instanceId.value);
        writefln("  Retention Period  : %d days", p.retentionPeriod);
        writefln("  Backup Window     : %s", p.backupWindow);
        writefln("  Status            : %s", p.status.to!string);
        writefln("  Backup Location   : %s", p.backupLocation);
        writefln("  Last Error        : %s", p.lastError);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

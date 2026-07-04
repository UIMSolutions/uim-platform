/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.backup_policy;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;

mixin(ShowModule!());

@safe:

class CliBackupPolicyView {
    void renderList(CliBackupPolicyModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Backup Policies ===");
        writefln("%-38s %-16s %-10s %-10s", "ID", "Schedule", "Retention", "Status");
        writeln("-".replicate(76));
        foreach (p; model.policies)
            writefln("%-38s %-16s %-10s %-10s",
                p.id.value, p.schedule, p.retentionDays.to!string ~ "d", p.status.to!string);
        writefln("Total: %d", model.policies.length);
    }

    void renderDetail(BackupPolicy p) {
        writeln("=== Backup Policy Detail ===");
        writefln("  ID              : %s", p.id.value);
        writefln("  Schedule        : %s", p.schedule);
        writefln("  Retention Days  : %d", p.retentionDays);
        writefln("  Storage Location: %s", p.storageLocation);
        writefln("  Status          : %s", p.status.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

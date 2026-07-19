/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.configuration;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;

mixin(ShowModule!());

@safe:

class CliConfigurationView {
    void renderList(CliConfigurationModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Configurations ===");
        writefln("%-38s %-38s", "ID", "Instance ID");
        writeln("-".replicate(78));
        foreach (c; model.configurations)
            writefln("%-38s %-38s", c.id.value, c.instanceId.value);
        writefln("Total: %d", model.configurations.length);
    }

    void renderDetail(Configuration c) {
        writeln("=== Configuration Detail ===");
        writefln("  ID                  : %s", c.id.value);
        writefln("  Instance ID         : %s", c.instanceId.value);
        writefln("  Audit Log Levels    : %s", c.auditLogLevels);
        writefln("  Backup Retention    : %d days", c.backupRetentionPeriod);
        writefln("  Locale              : %s", c.locale);
        writefln("  Max Connections     : %d", c.maxConnections);
        writefln("  Work Mem (kB)       : %d", c.workMem);
        writefln("  Shared Buffers (MB) : %d", c.sharedBuffersMb);
        writefln("  Maint. Window Day   : %s", c.maintenanceWindowDay);
        writefln("  Maint. Start Hour   : %d", c.maintenanceWindowStartHour);
        writefln("  Maint. Duration     : %d h", c.maintenanceWindowDuration);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

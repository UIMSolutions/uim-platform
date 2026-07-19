/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.presentation.cli.views.maintenance_window;

import uim.platform.postgres;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliMaintenanceWindowView {
    void renderList(CliMaintenanceWindowModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== PostgreSQL Maintenance Windows ===");
        writefln("%-38s %-10s %-8s %-12s %-12s", "ID", "Day", "Hour", "Duration", "Status");
        writeln("-".replicate(82));
        foreach (w; model.windows)
            writefln("%-38s %-10s %-8d %-12d %-12s",
                w.id.value, w.dayOfWeek, w.startHourUtc, w.durationHours, w.status.to!string);
        writefln("Total: %d", model.windows.length);
    }

    void renderDetail(MaintenanceWindow w) {
        writeln("=== Maintenance Window Detail ===");
        writefln("  ID                        : %s", w.id.value);
        writefln("  Instance ID               : %s", w.instanceId.value);
        writefln("  Day of Week               : %s", w.dayOfWeek);
        writefln("  Start Hour (UTC)          : %d", w.startHourUtc);
        writefln("  Duration Hours            : %d", w.durationHours);
        writefln("  Auto Minor Version Upgrade: %s", w.autoMinorVersionUpgrade ? "yes" : "no");
        writefln("  Status                    : %s", w.status.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

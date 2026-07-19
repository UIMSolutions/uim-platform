/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.metric;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;
import std.format : format;
mixin(ShowModule!());

@safe:

class CliMetricView {
    void renderList(CliMetricModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Metrics ===");
        writefln("%-38s %-16s %-10s %-10s %-8s", "ID", "Timestamp", "MemUsed", "Clients", "HitRate");
        writeln("-".replicate(86));
        foreach (m; model.metrics)
            writefln("%-38s %-16s %-10s %-10s %-8s",
                m.id.value, m.timestamp_.to!string,
                m.memoryUsedMb.to!string ~ "MB",
                m.connectedClients.to!string,
                format("%.1f%%", m.hitRate * 100));
        writefln("Total: %d", model.metrics.length);
    }

    void renderDetail(Metric m) {
        writeln("=== Metric Detail ===");
        writefln("  ID                    : %s", m.id.value);
        writefln("  Timestamp             : %d", m.timestamp_);
        writefln("  Memory Used           : %d MB", m.memoryUsedMb);
        writefln("  Memory Total          : %d MB", m.memoryTotalMb);
        writefln("  Connected Clients     : %d", m.connectedClients);
        writefln("  Commands/sec          : %d", m.commandsPerSecond);
        writefln("  Hit Rate              : %.2f%%", m.hitRate * 100);
        writefln("  Evicted Keys          : %d", m.evictedKeys);
        writefln("  Expired Keys          : %d", m.expiredKeys);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

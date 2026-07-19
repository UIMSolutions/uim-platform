/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.presentation.cli.views.cache_entry;

import uim.platform.redis;
import std.stdio : writeln, writefln;
import std.conv  : to;
mixin(ShowModule!());

@safe:

class CliCacheEntryView {
    void renderList(CliCacheEntryModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Cache Entries ===");
        writefln("%-38s %-24s %-12s %-8s", "ID", "Key", "Type", "TTL");
        writeln("-".replicate(86));
        foreach (e; model.entries)
            writefln("%-38s %-24s %-12s %-8s",
                e.id.value, e.key, e.entryType.to!string, e.ttl < 0 ? "forever" : e.ttl.to!string);
        writefln("Total: %d", model.entries.length);
    }

    void renderDetail(CacheEntry e) {
        writeln("=== Cache Entry Detail ===");
        writefln("  ID         : %s", e.id.value);
        writefln("  Key        : %s", e.key);
        writefln("  Type       : %s", e.entryType.to!string);
        writefln("  TTL        : %s", e.ttl < 0 ? "no expiry" : e.ttl.to!string ~ "s");
        writefln("  Value      : %s", e.value.length > 80 ? e.value[0..80] ~ "..." : e.value);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

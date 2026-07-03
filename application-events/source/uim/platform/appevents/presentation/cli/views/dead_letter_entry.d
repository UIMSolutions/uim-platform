/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.dead_letter_entry;

// import uim.platform.appevents.domain.entities.dead_letter_entry;
// import uim.platform.appevents.presentation.cli.models.dead_letter_entry;
// import std.stdio  : writeln, writefln;
// import std.conv   : to;
// import std.string : replicate;

import uim.platform.appevents;

// mixin(ShowModule!());

@safe:


class CliDeadLetterEntryView {
    void renderList(CliDeadLetterEntryModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Dead Letter Entries ===");
        writefln("%-38s %-12s %-6s", "ID", "Status", "Retries");
        writeln("-".replicate(60));
        foreach (i; model.items)
            writefln("%-38s %-12s %-6d", i.id.value, i.status.to!string, i.retryCount);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(DeadLetterEntry i) {
        writeln("=== Dead Letter Entry Detail ===");
        writefln("  ID                  : %s", i.id.value);
        writefln("  Original Message ID : %s", i.originalMessageId.value);
        writefln("  Channel ID          : %s", i.channelId.value);
        writefln("  Error Message       : %s", i.errorMessage);
        writefln("  Failed At           : %s", i.failedAt.to!string);
        writefln("  Retry Count         : %d", i.retryCount);
        writefln("  Status              : %s", i.status.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

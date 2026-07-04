/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.event_message;

// import uim.platform.appevents.domain.entities.event_message;
// import uim.platform.appevents.presentation.cli.models.event_message;
// import std.stdio  : writeln, writefln;
// import std.conv   : to;
// import std.string : replicate;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:


class CliEventMessageView {
    void renderList(CliEventMessageModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Event Messages ===");
        writefln("%-38s %-32s %-12s", "ID", "Event Type", "Status");
        writeln("-".replicate(86));
        foreach (i; model.items)
            writefln("%-38s %-32s %-12s", i.id.value, i.eventType, i.status.to!string);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(EventMessage i) {
        writeln("=== Event Message Detail ===");
        writefln("  ID              : %s", i.id.value);
        writefln("  Channel ID      : %s", i.channelId.value);
        writefln("  Event Type      : %s", i.eventType);
        writefln("  Payload         : %s", i.payload);
        writefln("  Source System   : %s", i.sourceSystemId);
        writefln("  Target System   : %s", i.targetSystemId);
        writefln("  Status          : %s", i.status.to!string);
        writefln("  Retry Count     : %d", i.retryCount);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

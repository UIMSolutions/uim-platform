/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.event_topic;

import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.presentation.cli.models.event_topic;
import std.stdio  : writeln, writefln;
import std.conv   : to;
import std.string : replicate;

@safe:

class CliEventTopicView {
    void renderList(CliEventTopicModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Event Topics ===");
        writefln("%-38s %-32s %-20s %-12s", "ID", "Name", "Namespace", "Status");
        writeln("-".replicate(106));
        foreach (i; model.items)
            writefln("%-38s %-32s %-20s %-12s", i.id.value, i.name, i.namespace, i.status.to!string);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(EventTopic i) {
        writeln("=== Event Topic Detail ===");
        writefln("  ID          : %s", i.id.value);
        writefln("  Name        : %s", i.name);
        writefln("  Namespace   : %s", i.namespace);
        writefln("  Description : %s", i.description);
        writefln("  Version     : %s", i.version_);
        writefln("  Category    : %s", i.category);
        writefln("  Status      : %s", i.status.to!string);
        writefln("  Owner ID    : %s", i.ownerId);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

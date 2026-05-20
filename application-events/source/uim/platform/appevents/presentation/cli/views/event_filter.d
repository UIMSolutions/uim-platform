/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.event_filter;

import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.presentation.cli.models.event_filter;
import std.stdio  : writeln, writefln;
import std.conv   : to;
import std.string : replicate;

@safe:

class CliEventFilterView {
    void renderList(CliEventFilterModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Event Filters ===");
        writefln("%-38s %-32s %-8s", "ID", "Attribute", "Active");
        writeln("-".replicate(82));
        foreach (i; model.items)
            writefln("%-38s %-32s %-8s", i.id.value, i.attribute, i.active.to!string);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(EventFilter i) {
        writeln("=== Event Filter Detail ===");
        writefln("  ID              : %s", i.id.value);
        writefln("  Subscription ID : %s", i.subscriptionId.value);
        writefln("  Filter Type     : %s", i.filterType);
        writefln("  Attribute       : %s", i.attribute);
        writefln("  Operator        : %s", i.operator_);
        writefln("  Value           : %s", i.value);
        writefln("  Active          : %s", i.active.to!string);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

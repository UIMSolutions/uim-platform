/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.presentation.cli.views.event_subscription;

import uim.platform.appevents.domain.entities.event_subscription;
import uim.platform.appevents.presentation.cli.models.event_subscription;
import std.stdio  : writeln, writefln;
import std.conv   : to;
import std.string : replicate;

@safe:

class CliEventSubscriptionView {
    void renderList(CliEventSubscriptionModel model) {
        if (model.errorMessage.length > 0) { writefln("ERROR: %s", model.errorMessage); return; }
        writeln("=== Event Subscriptions ===");
        writefln("%-38s %-32s %-12s", "ID", "Name", "Status");
        writeln("-".replicate(86));
        foreach (i; model.items)
            writefln("%-38s %-32s %-12s", i.id.value, i.name, i.status.to!string);
        writefln("Total: %d", model.items.length);
    }

    void renderDetail(EventSubscription i) {
        writeln("=== Event Subscription Detail ===");
        writefln("  ID                : %s", i.id.value);
        writefln("  Name              : %s", i.name);
        writefln("  Description       : %s", i.description);
        writefln("  Producer System   : %s", i.producerSystemId);
        writefln("  Consumer System   : %s", i.consumerSystemId);
        writefln("  Event Type        : %s", i.eventType);
        writefln("  Status            : %s", i.status.to!string);
        writefln("  Formation ID      : %s", i.formationId.value);
        writefln("  Max Retries       : %d", i.maxRetries);
    }

    void renderError(string msg)   { writefln("ERROR: %s", msg); }
    void renderSuccess(string msg) { writefln("OK: %s", msg); }
}

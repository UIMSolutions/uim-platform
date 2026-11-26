/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus event hub commands.
module uim.platform.application_events.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-application-events-cli";

CliApplication buildAehCli(AehContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;
  auto app = new CliApplication(cliProgram,
    "Application Event Hub administration: formations, systems, event catalog, channels, subscriptions with filters, "
    ~ "publishing, delivery and dead letters", output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");
  registerEntityCommands(app, engine);

  int show(CliContext c, Json row) {
    return c.emit(row, TextTable.keyValue(row, row.get!(Json[string]).keys.sort.array));
  }

  int invokeOn(CliContext c, string action, string what, Json extra = Json.emptyObject) @trusted {
    auto p = Json(["id": Json(c.operand(0, what))]);
    foreach (k, v; extra.get!(Json[string]))
      p[k] = v;
    auto r = engine.invoke(c.request, action, p);
    auto status = "status" in r && r["status"].type == Json.Type.string ? r["status"].get!string : "done";
    auto id = "id" in r && r["id"].type == Json.Type.string ? r["id"].get!string : c.operand(0, what);
    return c.done(r, what ~ " '" ~ id ~ "': " ~ status);
  }

  int published(CliContext c, Json r) {
    auto text = r["summary"].get!string;
    auto lines = r["outcomes"].get!string;
    auto notes = r["notes"].get!string;
    return c.done(r, "event " ~ r["eventId"].get!string ~ " (" ~ r["eventType"].get!string ~ "): " ~ text
        ~ (lines.length ? "\n" ~ lines : "") ~ (notes.length ? "\nnote: " ~ notes : ""));
  }

  int delivered(CliContext c, Json r) {
    return c.done(r, format("message %s → %s (%d attempts) %s", r["messageId"].get!string, r["status"].get!string,
      r["attempts"].get!long, r["message"].get!string));
  }

  Json eventParams(CliContext c) {
    auto p = Json(["type": Json(c.operand(0, "event type")), "source": Json(c.operand(1, "source system"))]);
    if (c.optionalOperand(2).length)
      p["data"] = c.optionalOperand(2);
    foreach (k; ["subject", "id", "time"])
      if (c.args.has(k))
        p[k] = c.args.opt(k);
    return p;
  }

  int listOf(CliContext c, string set, string[string] options, string[] columns) {
    auto page = engine.query(c.request, set, options);
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }

  string eq(string attribute, string value) {
    return attribute ~ " eq '" ~ value.replace("'", "''") ~ "'";
  }

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);
  app.command("seed", "", "Create the demo landscape in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d systems, %d event types, %d channels, %d subscriptions, "
      ~ "%d events → %d messages", c.request.tenantId, r["systems"].get!long, r["topics"].get!long,
      r["channels"].get!long, r["subscriptions"].get!long, r["events"].get!long, r["messages"].get!long));
  }, []);
  app.command("publish", "<event type> <source system> [<data JSON>] [--subject=<s>] [--id=<event id>] [--time=<ISO>]",
    "Publish a CloudEvent", (CliContext c) => published(c, engine.invoke(c.request, "PublishEvent", eventParams(c))),
    ["subject", "id", "time"]);
  app.command("preview", "<event type> <source system> [<data JSON>] [--subject=<s>]",
    "Show which subscriptions would receive an event (nothing is stored)", (CliContext c) =>
    published(c, engine.invoke(c.request, "PreviewRouting", eventParams(c))), ["subject", "id", "time"]);
  app.command("dispatch", "", "Deliver all due messages now", (CliContext c) =>
    show(c, engine.invoke(c.request, "DispatchDue", Json.emptyObject)), []);
  app.command("deliver", "<message>", "Attempt one open message now", (CliContext c) =>
    delivered(c, engine.invoke(c.request, "DeliverMessage", Json(["id": Json(c.operand(0, "message"))]))), []);
  app.command("ack", "<message>", "Acknowledge a queued message", (CliContext c) =>
    invokeOn(c, "AcknowledgeMessage", "Message"), []);
  app.command("pull", "<queue channel> [--max=<n>]", "Show the queued messages of a queue channel", (CliContext c) {
    auto messages = container.ports.delivery.pull(TenantId(c.request.tenantId), EventChannelId(c.operand(0, "channel")),
      cast(size_t) c.args.intOpt("max", 10), UserId(c.request.actor));
    Json[] rows;
    foreach (m; messages)
      rows ~= engine.read(c.request, "Messages", m.id.value);
    return c.emit(Json(rows), TextTable.fromRows(rows, ["id", "eventType", "subject", "createdAt", "payload"]));
  }, ["max"]);
  app.command("messages", "[<subscription>] [--status=<status>]", "Show messages (newest first)", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc", "$top": "50"];
    string[] filters;
    auto id = c.optionalOperand(0);
    if (id.length) {
      engine.read(c.request, "Subscriptions", id);
      filters ~= eq("subscriptionId", id);
    }
    if (c.args.has("status"))
      filters ~= eq("status", c.args.opt("status"));
    if (filters.length)
      options["$filter"] = filters.join(" and ");
    return listOf(c, "Messages", options, ["createdAt", "eventType", "subscriptionName", "status", "attempts", "lastError"]);
  }, ["status"]);
  app.command("dead-letters", "[<subscription>]", "Show the open dead letters", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc", "$filter": "status eq 'open'"];
    auto id = c.optionalOperand(0);
    if (id.length)
      options["$filter"] = "status eq 'open' and " ~ eq("subscriptionId", id);
    return listOf(c, "DeadLetters", options, ["id", "createdAt", "eventType", "subscriptionName", "attempts", "reason"]);
  }, []);
  app.command("requeue", "<dead letter> | --all [--subscription=<id>]", "Requeue dead letters", (CliContext c) {
    if (c.args.has("all")) {
      auto p = Json.emptyObject;
      if (c.args.has("subscription"))
        p["subscriptionId"] = c.args.opt("subscription");
      return show(c, engine.invoke(c.request, "RequeueDeadLetters", p));
    }
    return delivered(c, engine.invoke(c.request, "RequeueDeadLetter", Json(["id": Json(c.operand(0, "dead letter"))])));
  }, ["all", "subscription"]);
  app.command("discard", "<dead letter>", "Discard a dead letter", (CliContext c) =>
    invokeOn(c, "DiscardDeadLetter", "Dead letter"), []);
  app.command("pause", "<subscription>", "Pause a subscription", (CliContext c) =>
    invokeOn(c, "PauseSubscription", "Subscription"), []);
  app.command("resume", "<subscription>", "Resume a subscription", (CliContext c) =>
    invokeOn(c, "ResumeSubscription", "Subscription"), []);
  app.command("channel-status", "<channel> active|inactive|draining", "Change the status of a channel", (CliContext c) =>
    invokeOn(c, "SetChannelStatus", "Channel", Json(["status": Json(c.operand(1, "status"))])), []);
  app.command("type-status", "<event type id> active|deprecated|retired", "Change the status of an event type",
    (CliContext c) => invokeOn(c, "SetEventTypeStatus", "Event type", Json(["status": Json(c.operand(1, "status"))])), []);
  app.command("assign", "<formation> <system>", "Put a system into a formation", (CliContext c) {
    auto r = engine.invoke(c.request, "AssignSystem", Json(["id": Json(c.operand(0, "formation")),
        "systemId": Json(c.operand(1, "system"))]));
    return c.done(r, "'" ~ r["name"].get!string ~ "' belongs to '" ~ r["formationName"].get!string ~ "'");
  }, []);
  app.command("unassign", "<system>", "Remove a system from its formation", (CliContext c) {
    auto r = engine.invoke(c.request, "UnassignSystem", Json(["systemId": Json(c.operand(0, "system"))]));
    return c.done(r, "'" ~ r["name"].get!string ~ "' belongs to no formation now");
  }, []);
  app.command("filters", "<subscription>", "List the filters of a subscription", (CliContext c) {
    auto id = c.operand(0, "subscription");
    engine.read(c.request, "Subscriptions", id);
    return listOf(c, "Filters", ["$filter": eq("subscriptionId", id)], ["id", "summary", "active", "description"]);
  }, []);
  app.command("purge", "", "Remove finished messages and resolved dead letters beyond their retention", (CliContext c) =>
    show(c, engine.invoke(c.request, "PurgeMessages", Json.emptyObject)), []);
  app.command("capabilities", "", "Show what the service supports", (CliContext c) {
    c.print(capabilitiesJson(container.gateway.mode, config.policy).toPrettyString ~ "\n");
    return 0;
  }, []);
  app.command("token", "<user>", "Issue an access token for a user (authMode jwt, configured jwtSecret)", (CliContext c) {
    auto t = container.ports.users.issueToken(TenantId(c.request.tenantId), UserAccountId(c.operand(0, "user")));
    if (container.security.generatedSecret)
      c.print("warning: no jwtSecret configured — this token is only valid for this process\n");
    auto row = Json(["access_token": Json(t.accessToken), "token_type": Json(t.tokenType), "expires_in": Json(t.expiresIn)]);
    return c.done(row, t.accessToken);
  }, []);
  app.command("passwd", "<user> <new password>", "Set the password of a user (unlocks the account)", (CliContext c) {
    UpdateUserRequest r;
    r.tenantId = TenantId(c.request.tenantId);
    r.actor = UserId("cli");
    r.id = c.operand(0, "user");
    r.password = c.operand(1, "new password");
    auto u = container.ports.users.updateUser(r);
    return c.done(Json(["id": Json(u.id.value)]), "Password of '" ~ u.id.value ~ "' changed");
  }, []);
  app.command("config", "", "Show the effective configuration (secrets masked)", (CliContext c) {
    c.print(config.toMaskedJson().toPrettyString ~ "\n");
    return 0;
  }, []);
  return app;
}

/// Configuration overrides from the bootstrap options.
Json[string] cliOverrides(CliArgs a) {
  Json[string] o;
  if (a.has("data-file")) {
    o["storage"] = "file";
    o["dataFile"] = a.opt("data-file");
  }
  if (a.has("storage"))
    o["storage"] = a.opt("storage");
  return o;
}

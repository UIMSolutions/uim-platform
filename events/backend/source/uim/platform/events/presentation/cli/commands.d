/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus event mesh specific commands.
module uim.platform.events.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.events;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-event-mesh-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildEventsCli(EventsContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Event Mesh administration: messaging services, clients, queues, subscriptions, webhooks, channels, bindings, messages",
    output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("publish", "<topic> <payload|@file> [--service=ID | --client=ID] [--content-type=TYPE]",
    "Publish an event to a topic; it is copied into every queue whose subscription matches", (CliContext c) {
    auto p = Json.emptyObject;
    p["topic"] = c.operand(0, "topic");
    p["payload"] = payloadText(c.operand(1, "payload (text or @file)"));
    foreach (pair; [["service", "serviceId"], ["client", "clientId"], ["content-type", "contentType"]])
      if (c.args.has(pair[0]))
        p[pair[1]] = c.args.opt(pair[0]);
    auto result = engine.invoke(c.request, "PublishEvent", p);
    TextTable table;
    table.headers = ["Message", "Topic", "Queues", "Rejected"];
    table.rows ~= [result["messageId"].get!string, result["topic"].get!string, joinTexts(result["queueIds"]),
      joinTexts(result["rejectedQueueIds"])];
    return c.emit(result, table);
  }, ["service", "client", "content-type"]);

  app.command("consume", "<queueId> [--max=N] [--client=ID]", "Receive and acknowledge messages of a queue (FIFO)",
    (CliContext c) {
    auto p = Json.emptyObject;
    p["queueId"] = c.operand(0, "queue id");
    p["maxMessages"] = c.args.intOpt("max", 10);
    if (c.args.has("client"))
      p["clientId"] = c.args.opt("client");
    auto rows = engine.invoke(c.request, "ConsumeMessages", p);
    TextTable table;
    table.headers = ["Id", "Topic", "Published", "Payload"];
    foreach (m; (() @trusted => rows.get!(Json[]))())
      table.rows ~= [m["id"].get!string, m["topic"].get!string, cellText(m["createdAt"]), m["payload"].get!string];
    return c.emit(rows, table);
  }, ["max", "client"]);

  app.command("purge", "<queueId> --yes", "Remove all messages of a queue", (CliContext c) {
    auto queueId = c.operand(0, "queue id");
    if (!c.args.flag("yes"))
      throw new CliUsageError("purge removes all messages; confirm with --yes");
    auto p = Json.emptyObject;
    p["queueId"] = queueId;
    auto result = engine.invoke(c.request, "PurgeQueue", p);
    return c.done(result, format("Removed %d messages from '%s'", result["removed"].get!long, queueId));
  }, ["yes"]);

  app.command("deliver", "<webhookId> | --all", "Push queued messages to webhook endpoints now", (CliContext c) {
    DeliveryResult[] results;
    auto t = TenantId(c.request.tenantId);
    auto actor = UserId(c.request.actor);
    if (c.args.flag("all"))
      results = translated!(DeliveryResult[])(() => ports.delivery.deliverAll(t, actor));
    else
      results ~= translated!DeliveryResult(() => ports.delivery.deliver(t, WebhookId(c.operand(0, "webhook id (or --all)")), actor));

    auto data = Json.emptyArray;
    TextTable table;
    table.headers = ["Webhook", "Attempted", "Delivered", "Retried", "Dead Lettered", "Discarded", "Last Error"];
    foreach (r; results) {
      data ~= deliveryResultRow(r);
      table.rows ~= [r.webhookName, r.attempted.to!string, r.delivered.to!string, r.retried.to!string,
        r.deadLettered.to!string, r.discarded.to!string, r.lastError];
    }
    c.emit(data, table);
    return results.any!(r => r.attempted > r.delivered) ? 1 : 0;
  }, ["all"]);

  app.command("expire", "", "Remove expired messages of the tenant", (CliContext c) {
    auto n = translated!size_t(() => ports.consumer.removeExpired(TenantId(c.request.tenantId)));
    auto data = Json.emptyObject;
    data["removed"] = n;
    return c.done(data, format("Removed %d expired messages", n));
  }, []);

  app.command("seed", "", "Load a demo scenario (services, queues, subscriptions, clients, bindings, events) into an empty tenant",
    (CliContext c) {
    auto r = translated!DemoDataResult(() => seedDemoData(ports, TenantId(c.request.tenantId), UserId(c.request.actor)));
    auto data = Json.emptyObject;
    static foreach (name; ["services", "clients", "queues", "subscriptions", "webhooks", "channels", "bindings", "messages"])
      data[name] = __traits(getMember, r, name);
    return c.done(data, format("Seeded tenant '%s': %d services, %d queues, %d subscriptions, %d clients, %d bindings, %d channels, %d webhook, %d queued messages",
      c.request.tenantId, r.services, r.queues, r.subscriptions, r.clients, r.bindings, r.channels, r.webhooks, r.messages));
  }, []);

  app.command("config", "", "Show the effective configuration (secrets masked)", (CliContext c) {
    c.print(config.toMaskedJson().toPrettyString ~ "\n");
    return 0;
  }, []);

  return app;
}

/// Literal text, or the content of a file for "@path".
string payloadText(string arg) @trusted {
  import std.file : readText;

  return arg.startsWith("@") ? readText(arg[1 .. $]) : arg;
}

private string joinTexts(Json a) @trusted {
  string[] values;
  if (a.type == Json.Type.array)
    foreach (v; a)
      values ~= v.get!string;
  return values.join(", ");
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

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  auto gateway = new RecordingWebhookGateway;
  auto container = new EventsContainer(loadEventsConfig(o, "/nonexistent"), gateway);
  string out_;
  auto cli = buildEventsCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // tenant not empty → conflict
  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0, out_);
  auto stats = parseJsonString(out_);
  assert(stats["services"].get!long == 2 && stats["queues"].get!long == 3);
  assert(stats["queuedMessages"].get!long == 5, out_); // 2 created → 2 queues, 1 cancelled → audit

  out_ = "";
  assert(cli.run(["publish", "acme/sales/orders/ce/created", `{"orderId": "1"}`, "--service=sales-orders", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["queueIds"].length == 2);
  assert(cli.run(["publish", "other/ns/topic", "x", "--service=sales-orders"]) == 1); // outside namespace

  out_ = "";
  assert(cli.run(["consume", "orders-created", "--max=2", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length == 2);
  out_ = "";
  assert(cli.run(["list", "QueueMessages", "--filter=queueId eq 'orders-created'", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["value"].length == 1);

  // webhook push: activate, deliver (gateway answers 200)
  assert(cli.run(["update", "Webhooks", "erp-webhook", "--status=active"]) == 0);
  out_ = "";
  assert(cli.run(["deliver", "erp-webhook", "--json"]) == 0, out_);
  assert(parseJsonString(out_)[0]["delivered"].get!long == 1);
  assert(gateway.requests.length == 1 && gateway.requests[0].url == "https://erp.example.com/api/order-events");

  assert(cli.run(["delete", "Queues", "orders-created", "--yes"]) == 1); // still pushed by a webhook → 422
  assert(cli.run(["delete", "MessagingServices", "sales-orders", "--yes"]) == 1); // still has queues → 422
  assert(cli.run(["purge", "orders-audit", "--yes"]) == 0);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0);
  assert(cli.run(["stats", "--tenant=empty", "--json"]) == 0);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus service manager specific commands.
module uim.platform.service_manager.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-service-manager-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir", "async"];

CliApplication buildServiceManagerCli(ServiceManagerContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Service Manager administration: platforms, brokers, catalog, instances, bindings, operations, labels", output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");
  app.globalOption("async", "", "asynchronous provisioning (operations stay inProgress)");

  registerEntityCommands(app, engine);

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("sync-catalog", "<brokerId> | --all", "Fetch broker catalogs (OSB GET /v2/catalog) and reconcile offerings/plans",
    (CliContext c) {
    CatalogSyncResult[] results;
    auto t = TenantId(c.request.tenantId);
    auto actor = UserId(c.request.actor);
    if (c.args.flag("all"))
      results = translated!(CatalogSyncResult[])(() => ports.catalogSync.syncAll(t, actor));
    else
      results ~= translated!CatalogSyncResult(() => ports.catalogSync.syncCatalog(t,
        ServiceBrokerId(c.operand(0, "broker id (or --all)")), actor));

    auto data = Json.emptyArray;
    TextTable table;
    table.headers = ["Broker", "Result", "Offerings +/~/-", "Plans +/~"];
    foreach (r; results) {
      data ~= syncResultRow(r);
      table.rows ~= [r.brokerName, r.succeeded ? "ok" : "failed: " ~ r.error,
        format("%d/%d/%d", r.offeringsCreated, r.offeringsUpdated, r.offeringsRemoved),
        format("%d/%d", r.plansCreated, r.plansUpdated)];
    }
    c.emit(data, table);
    return results.any!(r => !r.succeeded) ? 1 : 0;
  }, ["all"]);

  app.command("complete-operation", "<operationId> [--failed] [--error=TEXT]",
    "Finish an in-progress operation (simulates the broker callback)", (CliContext c) {
    auto p = Json.emptyObject;
    p["operationId"] = c.operand(0, "operation id");
    p["succeeded"] = !c.args.flag("failed");
    if (c.args.has("error"))
      p["errorMessage"] = c.args.opt("error");
    auto result = engine.invoke(c.request, "CompleteOperation", p);
    return c.emit(result, TextTable.keyValue(result));
  }, ["failed", "error"]);

  app.command("seed", "", "Load demo platforms, a broker, catalog, an instance and a binding into an empty tenant",
    (CliContext c) {
    auto r = translated!DemoDataResult(() => seedDemoData(ports, TenantId(c.request.tenantId), UserId(c.request.actor)));
    auto data = Json.emptyObject;
    static foreach (name; ["platforms", "brokers", "offerings", "plans", "instances", "bindings", "labels"])
      data[name] = __traits(getMember, r, name);
    return c.done(data, format("Seeded tenant '%s': %d platforms, %d broker, %d offerings, %d plans, %d instance, %d binding",
      c.request.tenantId, r.platforms, r.brokers, r.offerings, r.plans, r.instances, r.bindings));
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
  if (a.flag("async"))
    o["syncProvisioning"] = false;
  return o;
}

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  auto container = new ServiceManagerContainer(loadServiceManagerConfig(o, "/nonexistent"));
  string out_;
  auto cli = buildServiceManagerCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // tenant not empty → conflict
  out_ = "";
  assert(cli.run(["list", "ServiceOfferings", "--filter=category eq 'data'", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["value"].length == 1);
  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0);
  auto stats = parseJsonString(out_);
  assert(stats["instances"].get!long == 1 && stats["bindings"].get!long == 1 && stats["plans"].get!long == 6);

  out_ = "";
  assert(cli.run(["list", "ServiceInstances", "--json"]) == 0);
  auto instanceId = parseJsonString(out_)["value"][0]["id"].get!string;
  assert(cli.run(["delete", "ServiceInstances", instanceId, "--yes"]) == 1); // still bound → 422
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0);
  assert(cli.run(["stats", "--tenant=empty", "--json"]) == 0);
}

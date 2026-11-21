/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus AI Core specific commands.
module uim.platform.ai_core.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-ai-core-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildAiCoreCli(AiCoreContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "AI Core administration: resource groups, scenarios, executables, configurations, executions, deployments, artifacts, schedules, metrics, secrets",
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

  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d resource groups, %d scenarios, %d executables, %d configurations, "
      ~ "%d artifacts, %d executions, %d deployments, %d schedules, %d metric values, %d secrets", c.request.tenantId,
      r["resourceGroups"].get!long, r["scenarios"].get!long, r["executables"].get!long, r["configurations"].get!long,
      r["artifacts"].get!long, r["executions"].get!long, r["deployments"].get!long, r["schedules"].get!long,
      r["metrics"].get!long, r["secrets"].get!long));
  }, []);

  app.command("reconcile", "[--times=N]", "Advance resource groups, executions, deployments and due schedules", (CliContext c) {
    auto times = c.args.intOpt("times", 1);
    ReconcileResult total;
    foreach (_; 0 .. times)
      total.add(ports.reconciler.reconcile(TenantId(c.request.tenantId)));
    auto row = reconcileRow(total);
    return c.emit(row, TextTable.keyValue(row, row.get!(Json[string]).keys.sort.array));
  }, ["times"]);

  app.command("run", "<resourceGroup> <configurationId>", "Start an execution of a workflow configuration", (CliContext c) {
    auto row = engine.create(c.request, "Executions", Json([
        "resourceGroupId": Json(c.operand(0, "resource group")), "configurationId": Json(c.operand(1, "configuration id"))
      ]));
    return c.done(row, "Execution " ~ row["id"].get!string ~ " submitted (" ~ row["status"].get!string ~ ")");
  }, []);

  app.command("deploy", "<resourceGroup> <configurationId> [--ttl=SECONDS]", "Deploy a serving configuration", (CliContext c) {
    auto payload = Json([
      "resourceGroupId": Json(c.operand(0, "resource group")), "configurationId": Json(c.operand(1, "configuration id"))
    ]);
    if (c.args.has("ttl"))
      payload["ttlSeconds"] = c.args.intOpt("ttl", 0);
    auto row = engine.create(c.request, "Deployments", payload);
    return c.done(row, "Deployment " ~ row["id"].get!string ~ " submitted (" ~ row["status"].get!string ~ ")");
  }, ["ttl"]);

  app.command("stop", "<Executions|Deployments> <key>", "Stop an execution or deployment", (CliContext c) {
    auto set = c.operand(0, "Executions or Deployments");
    auto action = set == "Executions" ? "StopExecution" : set == "Deployments" ? "StopDeployment" : "";
    if (action.length == 0)
      throw new CliUsageError("stop needs Executions or Deployments");
    auto row = engine.invoke(c.request, action, Json(["key": Json(c.operand(1, "key"))]));
    return c.done(row, row["id"].get!string ~ ": " ~ row["status"].get!string);
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

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["executionStartSeconds"] = 0;
  o["executionRunSeconds"] = 0;
  o["deploymentStartSeconds"] = 0;
  auto container = new AiCoreContainer(loadAiCoreConfig(o, "/nonexistent"));
  container.events.log = false;
  string out_;
  auto cli = buildAiCoreCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["list", "Executions"]) == 0 && cli.run(["stats"]) == 0);
  out_ = "";
  assert(cli.run(["run", "default", "train-default", "--json"]) == 0, out_);
  auto key = parseJsonString(out_)["key"].get!string;
  assert(cli.run(["reconcile", "--times=2"]) == 0);
  out_ = "";
  assert(cli.run(["get", "Executions", key, "--json"]) == 0, out_);
  assert(parseJsonString(out_)["status"].get!string == "COMPLETED", out_);
  assert(cli.run(["run", "default", "serve-v1"]) == 1); // serving → use deploy
  assert(cli.run(["deploy", "default", "serve-v1", "--ttl=3600"]) == 0);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0 && cli.run(["config"]) == 0);
}

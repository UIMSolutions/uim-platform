/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus AI Launchpad commands.
module uim.platform.ai_launchpad.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-ai-launchpad-cli";

CliApplication buildAilpCli(AilpContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;
  auto app = new CliApplication(cliProgram,
    "AI Launchpad administration: workspaces, AI runtime connections, resource groups, scenarios, configurations, "
    ~ "executions, deployments, models, datasets, prompts, launchpad tiles, users, roles and the audit log", output);
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

  int listOf(CliContext c, string set, string[string] options, string[] columns) {
    auto page = engine.query(c.request, set, options);
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }

  string eq(string attribute, string value) {
    return attribute ~ " eq '" ~ value.replace("'", "''") ~ "'";
  }

  /// Invoke an action on the operand; report "<what> '<id>': <status> — <message>".
  int invokeOn(CliContext c, string action, string what) {
    auto r = engine.invoke(c.request, action, Json(["id": Json(c.operand(0, what))]));
    auto message = "statusMessage" in r && r["statusMessage"].type == Json.Type.string ? r["statusMessage"].get!string : "";
    return c.done(r, format("%s '%s': %s%s", what, r["id"].get!string, r["status"].get!string,
      message.length ? " — " ~ message : ""));
  }

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);
  app.command("launchpad", "", "Show the launchpad tiles with their KPI values", (CliContext c) =>
    listOf(c, "LaunchpadTiles", ["$orderby": "sortOrder"], ["groupName", "title", "subtitle", "kpiValue", "kpiUnit",
      "target"]), []);
  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d workspaces, %d connections, %d scenarios, %d configurations, "
      ~ "%d executions, %d deployments, %d models, %d datasets, %d prompts", c.request.tenantId, r["workspaces"].get!long,
      r["connections"].get!long, r["scenarios"].get!long, r["configurations"].get!long, r["executions"].get!long,
      r["deployments"].get!long, r["models"].get!long, r["datasets"].get!long, r["prompts"].get!long));
  }, []);
  app.command("validate", "<connection>", "Validate a connection with its runtime", (CliContext c) {
    auto r = engine.invoke(c.request, "ValidateConnection", Json(["id": Json(c.operand(0, "connection"))]));
    auto rc = c.done(r, format("connection '%s': %s — %s", r["name"].get!string, r["status"].get!string,
      r["statusMessage"].get!string));
    return r["status"].get!string == "active" ? rc : 3;
  }, []);
  app.command("executions", "[--status=<status>] [--top=<n>]", "List the executions (newest first)", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc", "$top": c.args.opt("top", "30")];
    if (c.args.has("status"))
      options["$filter"] = eq("status", c.args.opt("status"));
    return listOf(c, "Executions", options, ["id", "configurationName", "resourceGroupId", "status", "startedAt",
      "durationSeconds", "statusMessage"]);
  }, ["status", "top"]);
  app.command("deployments", "[--status=<status>]", "List the deployments", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc"];
    if (c.args.has("status"))
      options["$filter"] = eq("status", c.args.opt("status"));
    return listOf(c, "Deployments", options, ["id", "configurationName", "status", "maxReplicas", "deploymentUrl"]);
  }, ["status"]);
  app.command("execute", "<configuration> [--resource-group=<id>]", "Start an execution of a configuration",
    (CliContext c) @trusted {
    auto p = Json(["configurationId": Json(c.operand(0, "configuration"))]);
    if (c.args.has("resource-group"))
      p["resourceGroupId"] = c.args.opt("resource-group");
    auto r = engine.create(c.request, "Executions", p);
    return c.done(r, format("execution '%s' of '%s': %s", r["id"].get!string, r["configurationId"].get!string,
      r["status"].get!string));
  }, ["resource-group"]);
  app.command("deploy", "<configuration> [--resource-group=<id>] [--replicas=<n>] [--ttl=<minutes>]",
    "Create a deployment of a configuration", (CliContext c) @trusted {
    auto p = Json(["configurationId": Json(c.operand(0, "configuration"))]);
    if (c.args.has("resource-group"))
      p["resourceGroupId"] = c.args.opt("resource-group");
    if (c.args.has("replicas"))
      p["maxReplicas"] = c.args.intOpt("replicas", 1);
    if (c.args.has("ttl"))
      p["ttlMinutes"] = c.args.intOpt("ttl", 0);
    auto r = engine.create(c.request, "Deployments", p);
    return c.done(r, format("deployment '%s' of '%s': %s", r["id"].get!string, r["configurationId"].get!string,
      r["status"].get!string));
  }, ["resource-group", "replicas", "ttl"]);
  app.command("stop", "<execution | deployment>", "Stop an execution or a deployment", (CliContext c) {
    auto id = c.operand(0, "execution or deployment");
    auto isExecution = engine.query(c.request, "Executions", ["$filter": eq("id", id)]).total > 0;
    return invokeOn(c, isExecution ? "StopExecution" : "StopDeployment", isExecution ? "execution" : "deployment");
  }, []);
  app.command("start", "<deployment>", "Restart a stopped or dead deployment", (CliContext c) =>
    invokeOn(c, "StartDeployment", "deployment"), []);
  app.command("reconcile", "", "Synchronize executions and deployments with the runtimes", (CliContext c) =>
    show(c, engine.invoke(c.request, "Reconcile", Json.emptyObject)), []);
  app.command("run-prompt", "<prompt> [name=value ...]", "Run a prompt in the playground", (CliContext c) @trusted {
    auto inputs = Json.emptyObject;
    for (size_t i = 1;; i++) {
      auto pair = c.optionalOperand(i);
      if (pair.length == 0)
        break;
      auto eqAt = pair.indexOf('=');
      if (eqAt <= 0)
        throw new Exception("input '" ~ pair ~ "' must have the form name=value");
      inputs[pair[0 .. eqAt]] = pair[eqAt + 1 .. $];
    }
    auto r = engine.invoke(c.request, "RunPrompt", Json(["id": Json(c.operand(0, "prompt")), "inputs": Json(inputs.toString)]));
    return c.done(r, r["output"].get!string);
  }, []);
  app.command("logs", "[--severity=<info|warning|error>] [--category=<category>] [--top=<n>]",
    "Show the audit log (newest first)", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc", "$top": c.args.opt("top", "30")];
    string[] filters;
    if (c.args.has("severity"))
      filters ~= eq("severity", c.args.opt("severity"));
    if (c.args.has("category"))
      filters ~= eq("category", c.args.opt("category"));
    if (filters.length)
      options["$filter"] = filters.join(" and ");
    return listOf(c, "LogEntries", options, ["createdAt", "severity", "category", "eventType", "actor", "message"]);
  }, ["severity", "category", "top"]);
  app.command("purge-logs", "", "Remove audit log entries beyond the retention", (CliContext c) =>
    show(c, engine.invoke(c.request, "PurgeLogs", Json.emptyObject)), []);
  app.command("restore-tiles", "", "Replace the tile catalog by the default tiles", (CliContext c) =>
    show(c, engine.invoke(c.request, "RestoreDefaultTiles", Json.emptyObject)), []);
  app.command("capabilities", "", "Show what the service supports", (CliContext c) {
    c.print(capabilitiesJson(container.runtime.mode, config.policy).toPrettyString ~ "\n");
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

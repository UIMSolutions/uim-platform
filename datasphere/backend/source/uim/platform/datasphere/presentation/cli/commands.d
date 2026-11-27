/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus Datasphere commands.
module uim.platform.datasphere.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-datasphere-cli";

CliApplication buildDspCli(DspContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;
  auto app = new CliApplication(cliProgram,
    "Datasphere administration: spaces, connections, remote tables, views, data flows, tasks and task chains, "
    ~ "data access controls, catalog and the run monitor", output);
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

  /// Invoke an action on the operand; report "<what> '<id>': <status>".
  int invokeOn(CliContext c, string action, string what, string statusField = "status", Json extra = Json.emptyObject) @trusted {
    auto p = Json(["id": Json(c.operand(0, what))]);
    foreach (k, v; extra.get!(Json[string]))
      p[k] = v;
    auto r = engine.invoke(c.request, action, p);
    auto status = statusField in r && r[statusField].type == Json.Type.string ? r[statusField].get!string : "done";
    auto id = "name" in r && r["name"].type == Json.Type.string ? r["name"].get!string : c.operand(0, what);
    return c.done(r, what ~ " '" ~ id ~ "': " ~ status);
  }

  /// Report a run (replication, data flow, persistence, task, chain).
  int ran(CliContext c, Json r) {
    auto text = format("%s %s '%s': %s — %s (%d rows, %d ms)", r["objectType"].get!string, r["id"].get!string,
      r["objectName"].get!string, r["status"].get!string, r["message"].get!string, r["rowsProcessed"].get!long,
      r["durationMs"].get!long);
    auto rc = c.done(r, text);
    return r["status"].get!string == "completed" ? rc : 3;
  }

  int runOn(CliContext c, string action, string what) {
    return ran(c, engine.invoke(c.request, action, Json(["id": Json(c.operand(0, what))])));
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
  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d spaces, %d connections, %d remote tables, %d views, %d data flows, "
      ~ "%d tasks, %d task chains, %d runs", c.request.tenantId, r["spaces"].get!long, r["connections"].get!long,
      r["remoteTables"].get!long, r["views"].get!long, r["dataFlows"].get!long, r["tasks"].get!long,
      r["taskChains"].get!long, r["runs"].get!long));
  }, []);
  app.command("spaces", "", "List the spaces with their disk usage", (CliContext c) =>
    listOf(c, "Spaces", ["$orderby": "id"], ["id", "name", "status", "usedDiskGiB", "diskQuotaGiB", "diskUsagePercent",
      "objectCount"]), []);
  app.command("lock", "<space> [--reason=<text>]", "Lock a space", (CliContext c) =>
    invokeOn(c, "LockSpace", "Space", "status", Json(["reason": Json(c.args.opt("reason", ""))])), ["reason"]);
  app.command("unlock", "<space>", "Unlock a space", (CliContext c) => invokeOn(c, "UnlockSpace", "Space"), []);
  app.command("validate", "<connection>", "Validate a connection", (CliContext c) {
    auto r = engine.invoke(c.request, "ValidateConnection", Json(["id": Json(c.operand(0, "connection"))]));
    auto rc = c.done(r, format("connection '%s': %s — %s", r["name"].get!string, r["status"].get!string,
      r["statusMessage"].get!string));
    return r["status"].get!string == "valid" ? rc : 3;
  }, []);
  app.command("replicate", "<remote table>", "Load a new snapshot of a remote table", (CliContext c) =>
    runOn(c, "ReplicateRemoteTable", "remote table"), []);
  app.command("deploy", "<view | data flow>", "Deploy a view or data flow", (CliContext c) @trusted {
    auto id = c.operand(0, "view or data flow");
    auto isView = engine.query(c.request, "Views", ["$filter": eq("id", id)]).total > 0;
    auto r = engine.invoke(c.request, isView ? "DeployView" : "DeployDataFlow", Json(["id": Json(id)]));
    return c.done(r, (isView ? "view '" : "data flow '") ~ r["name"].get!string ~ "': " ~ r["deploymentStatus"].get!string);
  }, []);
  app.command("persist", "<view>", "Persist (materialise) a view", (CliContext c) => runOn(c, "PersistView", "view"), []);
  app.command("run", "<task | task chain | data flow>", "Run a task, task chain or data flow now", (CliContext c) {
    auto id = c.operand(0, "task, task chain or data flow");
    string action = "RunDataFlow";
    if (engine.query(c.request, "Tasks", ["$filter": eq("id", id)]).total > 0)
      action = "RunTask";
    else if (engine.query(c.request, "TaskChains", ["$filter": eq("id", id)]).total > 0)
      action = "RunTaskChain";
    return ran(c, engine.invoke(c.request, action, Json(["id": Json(id)])));
  }, []);
  app.command("pause", "<task | task chain>", "Pause a schedule", (CliContext c) {
    auto id = c.operand(0, "task or task chain");
    auto chain = engine.query(c.request, "TaskChains", ["$filter": eq("id", id)]).total > 0;
    return invokeOn(c, chain ? "PauseTaskChain" : "PauseTask", chain ? "Task chain" : "Task");
  }, []);
  app.command("resume", "<task | task chain>", "Resume a schedule", (CliContext c) {
    auto id = c.operand(0, "task or task chain");
    auto chain = engine.query(c.request, "TaskChains", ["$filter": eq("id", id)]).total > 0;
    return invokeOn(c, chain ? "ResumeTaskChain" : "ResumeTask", chain ? "Task chain" : "Task");
  }, []);
  app.command("schedule", "", "Run the due tasks and task chains now", (CliContext c) =>
    show(c, engine.invoke(c.request, "RunDueSchedules", Json.emptyObject)), []);
  app.command("runs", "[<space>] [--status=<status>] [--top=<n>]", "Show the run log (newest first)", (CliContext c) {
    string[string] options = ["$orderby": "startedAt desc", "$top": c.args.opt("top", "30")];
    string[] filters;
    auto space = c.optionalOperand(0);
    if (space.length) {
      engine.read(c.request, "Spaces", space);
      filters ~= eq("spaceId", space);
    }
    if (c.args.has("status"))
      filters ~= eq("status", c.args.opt("status"));
    if (filters.length)
      options["$filter"] = filters.join(" and ");
    return listOf(c, "Runs", options, ["startedAt", "objectType", "objectName", "trigger", "status", "durationMs",
      "rowsProcessed", "message"]);
  }, ["status", "top"]);
  app.command("check-access", "<view> <user> <row JSON>", "Would the user see the row of the view?", (CliContext c) {
    auto r = engine.invoke(c.request, "CheckDataAccess", Json(["viewId": Json(c.operand(0, "view")),
        "user": Json(c.operand(1, "user")), "row": Json(c.operand(2, "row JSON"))]));
    auto rc = c.done(r, (r["allowed"].get!bool ? "allowed: " : "denied: ") ~ r["reason"].get!string);
    return r["allowed"].get!bool ? rc : 3;
  }, []);
  app.command("search", "<text> [--space=<id>]", "Search the catalog (best matches first)", (CliContext c) {
    auto assets = container.ports.catalog.search(TenantId(c.request.tenantId), c.operand(0, "text"),
      SpaceId(c.args.opt("space", "")));
    Json[] rows;
    foreach (a; assets)
      rows ~= engine.read(c.request, "CatalogAssets", a.id.value);
    return c.emit(Json(rows), TextTable.fromRows(rows, ["id", "businessName", "assetType", "spaceId", "qualityStatus",
      "tagsText"]));
  }, ["space"]);
  app.command("purge", "", "Remove finished runs beyond the retention", (CliContext c) =>
    show(c, engine.invoke(c.request, "PurgeRuns", Json.emptyObject)), []);
  app.command("capabilities", "", "Show what the service supports", (CliContext c) {
    c.print(capabilitiesJson(container.processing.mode, config.policy).toPrettyString ~ "\n");
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

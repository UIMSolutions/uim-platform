/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus integration automation commands.
module uim.platform.integration_automation.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-integration-automation-cli";

CliApplication buildIaCli(IaContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Integration automation administration: systems, destinations, scenarios and task templates, guided workflows, "
    ~ "tasks, automation runs and the execution log", output);
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

  int invokeOn(CliContext c, string action, string what, string[] extra = null) {
    auto p = Json(["id": Json(c.operand(0, what))]);
    foreach (i, name; extra)
      if (c.optionalOperand(i + 1).length)
        p[name] = c.optionalOperand(i + 1);
    auto r = engine.invoke(c.request, action, p);
    auto status = "status" in r && r["status"].type == Json.Type.string ? r["status"].get!string : "done";
    return c.done(r, what ~ " '" ~ r["id"].get!string ~ "': " ~ status);
  }

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d systems, %d destinations, %d scenarios (%d task templates), "
      ~ "%d workflows (%d tasks)", c.request.tenantId, r["systems"].get!long, r["destinations"].get!long,
      r["scenarios"].get!long, r["scenarioTasks"].get!long, r["workflows"].get!long, r["workflowTasks"].get!long));
  }, []);

  app.command("test", "<system>", "Test the connection of a system", (CliContext c) {
    auto r = engine.invoke(c.request, "TestSystemConnection", Json(["id": Json(c.operand(0, "system"))]));
    return c.done(r, "System '" ~ r["id"].get!string ~ "' is " ~ r["status"].get!string ~ ": " ~ r["lastTestMessage"].get!string);
  }, []);

  app.command("activate", "<scenario>", "Activate a scenario", (CliContext c) => invokeOn(c, "ActivateScenario", "Scenario"), []);
  app.command("deprecate", "<scenario>", "Deprecate a scenario", (CliContext c) => invokeOn(c, "DeprecateScenario", "Scenario"), []);
  app.command("archive", "<scenario>", "Archive a scenario", (CliContext c) => invokeOn(c, "ArchiveScenario", "Scenario"), []);
  app.command("copy", "<scenario> [<new id>]", "Copy a scenario as a new draft version",
    (CliContext c) => invokeOn(c, "CopyScenario", "Scenario", ["newId"]), []);

  app.command("instantiate", "<scenario> [--name=<text>] [--source=<system>] [--target=<system>] [--start]",
    "Create a workflow from an active scenario", (CliContext c) {
    auto p = Json(["scenarioId": Json(c.operand(0, "scenario"))]);
    foreach (option, member; ["name": "name", "source": "sourceSystemId", "target": "targetSystemId"])
      if (c.args.has(option))
        p[member] = c.args.opt(option);
    auto r = engine.create(c.request, "Workflows", p);
    if (c.args.has("start"))
      r = engine.invoke(c.request, "StartWorkflow", Json(["id": r["id"]]));
    return c.done(r, format("Workflow '%s' (%s) %s with %d tasks", r["id"].get!string, r["name"].get!string,
      r["status"].get!string, r["totalTasks"].get!long));
  }, ["name", "source", "target", "start"]);

  app.command("start", "<workflow>", "Start a planned workflow", (CliContext c) => invokeOn(c, "StartWorkflow", "Workflow"), []);
  app.command("suspend", "<workflow>", "Suspend a workflow", (CliContext c) => invokeOn(c, "SuspendWorkflow", "Workflow"), []);
  app.command("resume", "<workflow>", "Resume a suspended workflow", (CliContext c) => invokeOn(c, "ResumeWorkflow", "Workflow"), []);
  app.command("terminate", "<workflow> [<reason>]", "Terminate a workflow",
    (CliContext c) => invokeOn(c, "TerminateWorkflow", "Workflow", ["reason"]), []);

  app.command("tasks", "<workflow>", "List the tasks of a workflow in sequence", (CliContext c) {
    auto id = c.operand(0, "workflow");
    engine.read(c.request, "Workflows", id);
    auto page = engine.query(c.request, "WorkflowTasks", ["$filter": "workflowId eq '" ~ id.replace("'", "''") ~ "'",
        "$orderby": "sequenceNumber"]);
    auto columns = ["sequenceNumber", "id", "name", "taskType", "status", "ready", "assignedTo", "waitingFor"];
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }, []);

  app.command("task-start", "<task>", "Start a task", (CliContext c) => invokeOn(c, "StartTask", "Task"), []);
  app.command("complete", "<task> [<result>]", "Complete (or approve) a task",
    (CliContext c) => invokeOn(c, "CompleteTask", "Task", ["result"]), []);
  app.command("fail", "<task> <error message>", "Fail (or reject) a task", (CliContext c) {
    c.operand(1, "error message");
    return invokeOn(c, "FailTask", "Task", ["errorMessage"]);
  }, []);
  app.command("skip", "<task> <reason>", "Skip a task", (CliContext c) {
    c.operand(1, "reason");
    return invokeOn(c, "SkipTask", "Task", ["reason"]);
  }, []);
  app.command("retry", "<task>", "Set a failed task back to pending", (CliContext c) => invokeOn(c, "RetryTask", "Task"), []);
  app.command("assign", "<task> <user> [<priority>]", "Assign a task to a user ('-' unassigns)", (CliContext c) {
    auto p = Json(["id": Json(c.operand(0, "task"))]);
    auto user = c.operand(1, "user");
    p["assignedTo"] = user == "-" ? "" : user;
    if (c.optionalOperand(2).length)
      p["priority"] = c.optionalOperand(2);
    auto r = engine.invoke(c.request, "AssignTask", p);
    return c.done(r, "Task '" ~ r["id"].get!string ~ "' assigned to '" ~ r["assignedTo"].get!string ~ "'");
  }, []);

  app.command("run", "[<workflow>]", "Run the ready automated and notification tasks", (CliContext c) {
    auto p = Json.emptyObject;
    if (c.optionalOperand(0).length)
      p["workflowId"] = c.optionalOperand(0);
    return show(c, engine.invoke(c.request, "RunAutomatedTasks", p));
  }, []);

  app.command("purge", "<days>", "Remove execution log entries older than the given days", (CliContext c) {
    auto r = engine.invoke(c.request, "PurgeExecutionLogs", Json(["olderThanDays": Json(c.operand(0, "days"))]));
    return c.done(r, format("%d execution log entries removed", r["removed"].get!long));
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

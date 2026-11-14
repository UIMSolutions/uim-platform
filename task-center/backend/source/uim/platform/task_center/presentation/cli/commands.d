/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus task center specific commands (inbox, task actions,
/// history, comments, provider sync, saved filters, demo data).
module uim.platform.task_center.presentation.cli.commands;

import std.traits : EnumMembers;
import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-task-center-cli";

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildTaskCenterCli(TaskCenterContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Task Center administration: unified inbox, task actions, providers, definitions, substitutions, filters", output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("user", "<id>", "user performing the actions (default: cli)");
  app.globalOption("storage", "memory|file", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  app.command("stats", "", "Show the key figures of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("inbox", "[--all] [--filter=EXPR]", "Unfinished tasks of --user (all users with --all), most urgent first",
    (CliContext c) {
    string[] terms = ["status ne 'completed'", "status ne 'cancelled'", "status ne 'failed'"];
    if (!c.args.flag("all"))
      terms ~= "assignee eq '" ~ c.request.actor.replace("'", "''") ~ "'";
    if (c.args.has("filter"))
      terms ~= "(" ~ c.args.opt("filter") ~ ")";
    string[string] options = ["$filter": terms.join(" and "), "$orderby": "dueDate asc"];
    auto page = engine.query(c.request, "Tasks", options);
    auto rows = page.rows.dup;
    rows.sort!((a, b) => urgency(a) > urgency(b));
    return c.emit(Json(rows), taskTable(rows));
  }, ["all", "filter"]);

  static foreach (action; EnumMembers!ActionType)
    app.command(cast(string) action, action == ActionType.forward ? "<taskId> <toUser> [--comment=TEXT]" : "<taskId> [--comment=TEXT]",
      actionSummary(action), (CliContext c) {
      auto p = Json.emptyObject;
      p["taskId"] = c.operand(0, "task id");
      p["action"] = cast(string) action;
      if (action == ActionType.forward)
        p["forwardTo"] = c.operand(1, "recipient");
      if (c.args.has("comment"))
        p["comment"] = c.args.opt("comment");
      auto task = engine.invoke(c.request, "PerformTaskAction", p);
      return c.done(task, format("%s: '%s' is now %s%s (assignee %s)", cast(string) action, task["title"].get!string,
        task["status"].get!string, task["outcome"].get!string == "none" ? "" : "/" ~ task["outcome"].get!string,
        cellText(task["assignee"])));
    }, ["comment"]);

  app.command("history", "<taskId>", "Show the action history of a task", (CliContext c) {
    auto id = c.operand(0, "task id");
    engine.read(c.request, "Tasks", id);
    string[string] options = ["$filter": "taskId eq '" ~ id.replace("'", "''") ~ "'", "$orderby": "performedAt asc"];
    auto rows = engine.query(c.request, "TaskActions", options).rows;
    TextTable table;
    table.headers = ["When", "Action", "By", "From", "To", "Forwarded To", "Comment"];
    foreach (r; rows)
      table.rows ~= [cellText(r["performedAt"]), cellText(r["actionType"]), cellText(r["performedBy"]),
        cellText(r["fromStatus"]), cellText(r["toStatus"]), cellText(r["forwardTo"]), cellText(r["comment"])];
    return c.emit(Json(rows), table);
  }, []);

  app.command("comment", "<taskId> <text>", "Add a comment to a task (as --user)", (CliContext c) {
    auto p = Json.emptyObject;
    p["taskId"] = c.operand(0, "task id");
    p["content"] = c.operands.length > 1 ? c.operands[1 .. $].join(" ") : c.operand(1, "comment text");
    auto row = engine.create(c.request, "TaskComments", p);
    return c.done(row, "Comment " ~ row["id"].get!string ~ " added");
  }, []);

  app.command("sync", "<providerId> | --all", "Pull the tasks of a provider (or of all active providers) now", (CliContext c) {
    Json results = Json.emptyArray;
    if (c.args.flag("all"))
      results = engine.invoke(c.request, "SyncAllProviders", Json.emptyObject);
    else
      results ~= engine.invoke(c.request, "SyncProvider", param("providerId", c.operand(0, "provider id (or --all)")));
    TextTable table;
    table.headers = ["Provider", "Fetched", "Created", "Updated", "Skipped", "Error"];
    bool failed;
    foreach (r; (() @trusted => results.get!(Json[]))()) {
      table.rows ~= [cellText(r["providerName"]), cellText(r["fetched"]), cellText(r["created"]), cellText(r["updated"]),
        cellText(r["skipped"]), cellText(r["error"])];
      failed |= r["error"].type == Json.Type.string;
    }
    c.emit(results, table);
    return failed ? 1 : 0;
  }, ["all"]);

  app.command("filter", "<filterId>", "List the tasks matching a saved filter", (CliContext c) {
    auto f = engine.read(c.request, "UserTaskFilters", c.operand(0, "filter id"));
    string[string] options;
    auto expr = f["odataFilter"].get!string;
    if (expr.length > 0)
      options["$filter"] = expr;
    auto rows = engine.query(c.request, "Tasks", options).rows;
    if (!c.json)
      c.print("Filter '" ~ f["name"].get!string ~ "': " ~ (expr.length ? expr : "(all tasks)") ~ "\n");
    return c.emit(Json(rows), taskTable(rows));
  }, []);

  app.command("seed", "", "Load a demo scenario (providers, definitions, tasks, substitutions, filters) into an empty tenant",
    (CliContext c) {
    auto r = translated!DemoDataResult(() => seedDemoData(ports, TenantId(c.request.tenantId), UserId(c.request.actor)));
    auto data = Json.emptyObject;
    static foreach (name; ["providers", "definitions", "tasks", "actions", "comments", "attachments", "substitutions", "filters"])
      data[name] = __traits(getMember, r, name);
    return c.done(data, format("Seeded tenant '%s': %d providers, %d definitions, %d tasks, %d actions, %d comments, %d attachment, %d substitutions, %d filter",
      c.request.tenantId, r.providers, r.definitions, r.tasks, r.actions, r.comments, r.attachments, r.substitutions, r.filters));
  }, []);

  app.command("config", "", "Show the effective configuration (secrets masked)", (CliContext c) {
    c.print(config.toMaskedJson().toPrettyString ~ "\n");
    return 0;
  }, []);

  return app;
}

private Json param(string name, string value) {
  auto p = Json.emptyObject;
  p[name] = value;
  return p;
}

private string actionSummary(ActionType a) {
  final switch (a) {
  case ActionType.claim:
    return "Claim a task (you become its processor)";
  case ActionType.release:
    return "Release a task you claimed";
  case ActionType.forward:
    return "Forward a task to another user";
  case ActionType.approve:
    return "Approve a task";
  case ActionType.reject:
    return "Reject a task";
  case ActionType.complete:
    return "Complete a task";
  case ActionType.cancel:
    return "Cancel a task";
  case ActionType.escalate:
    return "Raise the priority of a task";
  case ActionType.resubmit:
    return "Reopen a finished task";
  }
}

/// Sort key: overdue first, then priority, then due date.
private long urgency(Json row) @trusted {
  long score;
  if (row["isOverdue"].type == Json.Type.bool_ && row["isOverdue"].get!bool)
    score += 1000;
  score += 100 * rankOf(tolerant!TaskPriority(cellText(row["priority"]), TaskPriority.medium));
  return score;
}

private TextTable taskTable(Json[] rows) {
  TextTable table;
  table.headers = ["Id", "Title", "Status", "Priority", "Assignee", "Due", "Overdue", "Source"];
  foreach (r; rows)
    table.rows ~= [cellText(r["id"]), cellText(r["title"]), cellText(r["status"]), cellText(r["priority"]),
      cellText(r["assignee"]), cellText(r["dueDate"]), cellText(r["isOverdue"]), cellText(r["sourceApplication"])];
  return table;
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
  auto gateway = new StaticTaskProviderGateway;
  auto container = new TaskCenterContainer(loadTaskCenterConfig(o, "/nonexistent"), gateway, null, new NullTaskEventPublisher);
  string out_;
  auto cli = buildTaskCenterCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // tenant not empty → conflict
  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0, out_);
  auto stats = parseJsonString(out_);
  assert(stats["tasks"].get!long == 7 && stats["approvedTasks"].get!long == 1 && stats["activeSubstitutions"].get!long == 1, out_);

  // dora is absent: her purchase order went to ben
  out_ = "";
  assert(cli.run(["get", "Tasks", "po-4713", "--json"]) == 0, out_);
  auto po = parseJsonString(out_);
  assert(po["assignee"].get!string == "ben" && po["substitutedFor"].get!string == "dora", out_);

  // anna claimed po-4711: ben may not approve, anna may
  assert(cli.run(["approve", "po-4711", "--user=ben"]) == 1);
  out_ = "";
  assert(cli.run(["approve", "po-4711", "--user=anna", "--comment=Terms checked", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["outcome"].get!string == "approved");
  out_ = "";
  assert(cli.run(["history", "po-4711", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length == 2); // claim, approve

  // po-4712 requires a claim before a decision
  assert(cli.run(["reject", "po-4712", "--user=anna"]) == 1);
  assert(cli.run(["claim", "po-4712", "--user=anna"]) == 0);
  assert(cli.run(["forward", "po-4712", "dora", "--user=anna"]) == 0);
  out_ = "";
  assert(cli.run(["get", "Tasks", "po-4712", "--json"]) == 0);
  assert(parseJsonString(out_)["assignee"].get!string == "ben"); // forwarded to dora → substitute ben

  out_ = "";
  assert(cli.run(["inbox", "--user=ben", "--json"]) == 0, out_);
  auto inbox = parseJsonString(out_);
  assert(inbox.length == 2 && inbox[0]["id"].get!string == "po-4712", out_); // overdue first

  out_ = "";
  assert(cli.run(["filter", "anna-urgent", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length == 0, out_); // anna's urgent work is done

  assert(cli.run(["comment", "leave-ben", "Team", "calendar", "checked", "--user=carl"]) == 0);
  assert(cli.run(["delete", "TaskProviders", "s4hana-procurement", "--yes"]) == 1); // still has definitions → 422

  // federation through the gateway
  gateway.feeds["https://s4hana.example.com/sap/opu/odata4/sap/api_workflow/tasks"] = [
    ProviderTask("PO-4500004713", "Approve purchase order 4500004713 (56,000 EUR)", "", "", "veryHigh"),
    ProviderTask("PO-4500009999", "Approve purchase order 4500009999", "", "READY", "", "", "", "S4", "", "Purchase Order Approval")
  ];
  gateway.failures["https://api.successfactors.example.com/odata/v2/Todo"] = "connection refused";
  out_ = "";
  assert(cli.run(["sync", "--all", "--json"]) == 1, out_); // SuccessFactors failed
  auto results = parseJsonString(out_);
  assert(results[0]["created"].get!long == 1 && results[0]["updated"].get!long == 1, out_);
  out_ = "";
  assert(cli.run(["list", "Tasks", "--filter=externalTaskId eq 'PO-4500009999'", "--json"]) == 0);
  auto imported = parseJsonString(out_)["value"][0];
  assert(imported["definitionId"].get!string == "po-approval" && imported["priority"].get!string == "high", out_);
  out_ = "";
  assert(cli.run(["get", "TaskProviders", "successfactors-hr", "--json"]) == 0);
  assert(parseJsonString(out_)["status"].get!string == "error");

  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0);
  assert(cli.run(["stats", "--tenant=empty", "--json"]) == 0);
}

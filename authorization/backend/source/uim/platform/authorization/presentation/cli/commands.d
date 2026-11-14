/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus authorization specific commands.
///
/// Exit codes: 0 ok / permitted · 1 error · 2 usage · 3 denied (check)
module uim.platform.authorization.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-authorization-cli";

/// Exit code of a denied authorization check.
enum int cliDenied = 3;

/// Options that select storage/configuration; read before the container is built.
enum string[] cliBootstrapOptions = ["storage", "data-file", "config-dir"];

CliApplication buildAuthorizationCli(AuthorizationContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto ports = container.ports;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Authorization Management: applications, APIs, policies, assignments, checks and the decision log", output);
  app.defaultTenant = config.defaultTenant;
  app.defaultUser = "cli";
  app.globalOption("tenant", "<id>", "tenant to operate on (default: " ~ app.defaultTenant ~ ")");
  app.globalOption("storage", "memory|file|mongodb", "storage backend (default: " ~ config.storage ~ ")");
  app.globalOption("data-file", "<path>", "JSON snapshot shared with server and GUI (implies --storage=file)");
  app.globalOption("config-dir", "<dir>", "directory with default.json (default: config)");

  registerEntityCommands(app, engine);

  Json invokeAction(CliContext c, string action, Json p) {
    return engine.invoke(c.request, action, p);
  }

  int actionResult(CliContext c, Json result) {
    return c.done(result, result["message"].get!string);
  }

  app.command("check", "<principal> <application> <resource> <action> [--groups=A,B] [--attributes=k=v,..] [--no-record]",
    "Evaluate an authorization request (exit 0 = permitted, 3 = denied)", (CliContext c) {
    auto p = Json.emptyObject;
    p["principalId"] = c.operand(0, "principal");
    p["application"] = c.operand(1, "application (id or name)");
    p["resource"] = c.operand(2, "resource");
    p["action"] = c.operand(3, "action");
    p["groups"] = c.args.opt("groups");
    p["attributes"] = c.args.opt("attributes");
    p["record"] = c.args.opt("record", "true") != "false" && !c.args.flag("no-record");
    auto r = invokeAction(c, "EvaluateAuthorization", p);
    auto allowed = r["allowed"].get!bool;
    c.emit(r, TextTable.keyValue(r, ["allowed", "reason", "matchedPolicies", "candidatePolicies", "decisionId"]));
    return allowed ? 0 : cliDenied;
  }, ["groups", "attributes", "record", "no-record"]);

  app.command("effective", "<principal> [--groups=A,B] [--application=ID|NAME]",
    "List the active policies effectively assigned to a user (and its groups)", (CliContext c) {
    auto t = TenantId(c.request.tenantId);
    ManagedApplicationId appId;
    if (c.args.has("application"))
      appId = translated!ManagedApplication(() => ports.applications.resolveApplication(t, c.args.opt("application"))).id;
    Json[] rows;
    foreach (p; ports.evaluation.effectivePolicies(t, c.operand(0, "principal"), splitList(c.args.opt("groups")), appId))
      rows ~= engine.read(c.request, "Policies", p.id.value);
    auto columns = ["name", "applicationName", "resource", "action", "conditions", "id"];
    return c.emit(Json(rows), TextTable.fromRows(rows, columns));
  }, ["groups", "application"]);

  app.command("stats", "", "Show the figures of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("seed", "", "Load demo applications, policies, assignments and decisions into an empty tenant",
    (CliContext c) => actionResult(c, invokeAction(c, "SeedDemoData", Json.emptyObject)), []);

  app.command("seed-base", "<application>", "Create the missing base policies of an application (id or name)",
    (CliContext c) {
    auto p = Json.emptyObject;
    p["application"] = c.operand(0, "application (id or name)");
    return actionResult(c, invokeAction(c, "SeedBasePolicies", p));
  }, []);

  foreach (name; ["enable", "disable"]) {
    auto action = name == "enable" ? "EnablePolicy" : "DisablePolicy";
    app.command(name, "<policyId>", (name == "enable" ? "Activate" : "Disable") ~ " a policy", (CliContext c) {
      auto p = Json.emptyObject;
      p["id"] = c.operand(0, "policy id");
      return actionResult(c, invokeAction(c, action, p));
    }, []);
  }

  app.command("prune", "[--days=N]", "Remove decision log entries older than N days (default: retention)",
    (CliContext c) {
    auto p = Json.emptyObject;
    p["olderThanDays"] = c.args.intOpt("days", config.decisionRetentionDays);
    return actionResult(c, invokeAction(c, "PruneDecisions", p));
  }, ["days"]);

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
  o["seedBasePolicies"] = false; // the CLI never seeds implicitly
  return o;
}

///
unittest {
  mixin(ShowTest!("AuthorizationCli"));

  Json[string] o;
  o["storage"] = "memory";
  auto container = new AuthorizationContainer(loadAuthorizationConfig(o, "/nonexistent"));
  string out_;
  auto cli = buildAuthorizationCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // tenant not empty → conflict
  out_ = "";
  assert(cli.run(["list", "Policies", "--filter=kind eq 'custom'", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["value"].length == 2);

  assert(cli.run(["check", "alice", "incident-management", "Incident", "Read", "--attributes=country=US"]) == 0);
  assert(cli.run(["check", "alice", "incident-management", "Incident", "Read", "--attributes=country=DE"]) == cliDenied);
  assert(cli.run(["check", "dave", "incident-management", "Incident", "Read", "--groups=Administrators"]) == 0);
  assert(cli.run(["check", "x", "missing-app", "Incident", "Read"]) == 1);

  out_ = "";
  assert(cli.run(["effective", "alice", "--json"]) == 0);
  assert(parseJsonString(out_).length == 1);

  out_ = "";
  assert(cli.run(["stats", "--json"]) == 0);
  auto stats = parseJsonString(out_);
  assert(stats["applications"].get!long == 2 && stats["assignments"].get!long == 5);
  assert(stats["decisions"].get!long == 5, stats.toString); // 2 demo checks + 3 recorded checks above

  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0);
  assert(cli.run(["nonsense"]) == 2);
}

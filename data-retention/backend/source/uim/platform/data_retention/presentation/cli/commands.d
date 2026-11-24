/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus data retention commands.
module uim.platform.data_retention.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-data-retention-cli";

CliApplication buildDrCli(DrContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;

  auto app = new CliApplication(cliProgram,
    "Data retention administration: application groups, business purposes, legal grounds, residence and retention "
    ~ "rules, data subjects, end-of-purpose checks, deletion requests and archiving jobs", output);
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

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);

  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d application groups, %d business purposes, %d legal grounds, "
      ~ "%d data subjects, %d deletion requests, %d archiving jobs", c.request.tenantId, r["applicationGroups"].get!long,
      r["businessPurposes"].get!long, r["legalGrounds"].get!long, r["dataSubjects"].get!long,
      r["deletionRequests"].get!long, r["archivingJobs"].get!long));
  }, []);

  app.command("check", "[<application group>] [--simulate]",
    "End-of-purpose check: block data subjects past their end of purpose, mark expired ones for deletion", (CliContext c) {
    auto p = Json(["simulate": Json(c.args.has("simulate"))]);
    auto group = c.optionalOperand(0);
    if (group.length)
      p["applicationGroupId"] = group;
    return show(c, engine.invoke(c.request, "CheckEndOfPurpose", p));
  }, ["simulate"]);

  app.command("simulate", "<business purpose> <reference date> [--legal-ground=<id>]",
    "Show end of purpose and end of retention for a reference date", (CliContext c) {
    auto p = Json(["businessPurposeId": Json(c.operand(0, "business purpose")), "referenceDate": Json(c.operand(1,
        "reference date"))]);
    if (c.args.has("legal-ground"))
      p["legalGroundId"] = c.args.opt("legal-ground");
    return show(c, engine.invoke(c.request, "SimulateRetention", p));
  }, ["legal-ground"]);

  app.command("activate", "<business purpose>", "Activate a business purpose", (CliContext c) {
    auto r = engine.invoke(c.request, "ActivateBusinessPurpose", Json(["id": Json(c.operand(0, "business purpose"))]));
    return c.done(r, "Business purpose '" ~ r["id"].get!string ~ "' is " ~ r["status"].get!string);
  }, []);

  app.command("block", "<data subject>", "Block a data subject", (CliContext c) {
    auto r = engine.invoke(c.request, "BlockDataSubject", Json(["id": Json(c.operand(0, "data subject"))]));
    return c.done(r, "Data subject '" ~ r["id"].get!string ~ "' is " ~ r["lifecycleStatus"].get!string);
  }, []);

  app.command("hold", "<data subject> <reason> | <data subject> --release", "Set or release a legal hold", (CliContext c) {
    auto release = c.args.has("release");
    auto p = Json(["id": Json(c.operand(0, "data subject")), "legalHold": Json(!release)]);
    if (!release)
      p["reason"] = c.operand(1, "reason");
    auto r = engine.invoke(c.request, "SetLegalHold", p);
    return c.done(r, "Legal hold of '" ~ r["id"].get!string ~ "' " ~ (release ? "released" : "set"));
  }, ["release"]);

  app.command("erase", "<data subject> [--action=delete|anonymize|block] [--reason=<text>]",
    "Create and process a deletion request", (CliContext c) {
    auto p = Json(["dataSubjectId": Json(c.operand(0, "data subject")), "action": Json(c.args.opt("action", "delete")),
        "reason": Json(c.args.opt("reason", "CLI request"))]);
    auto r = engine.create(c.request, "DeletionRequests", p);
    if (r["status"].get!string == "pending")
      r = engine.invoke(c.request, "ProcessDeletionRequest", Json(["id": r["id"]]));
    return c.done(r, format("Deletion request %s %s: %s", r["id"].get!string, r["status"].get!string,
      r["resultMessage"].type == Json.Type.string ? r["resultMessage"].get!string : ""));
  }, ["action", "reason"]);

  app.command("process", "", "Process all pending deletion requests", (CliContext c) {
    return show(c, engine.invoke(c.request, "ProcessPendingRequests", Json.emptyObject));
  }, []);

  app.command("run-job", "<archiving job>", "Run an archiving job now", (CliContext c) {
    auto r = engine.invoke(c.request, "RunArchivingJob", Json(["id": Json(c.operand(0, "archiving job"))]));
    return c.done(r, format("Archiving job %s %s: %d selected, %d archived, %d destroyed, %d skipped%s", r["id"].get!string,
      r["status"].get!string, r["selected"].get!long, r["archived"].get!long, r["destroyed"].get!long,
      r["skipped"].get!long, r["dryRun"].get!bool ? " (dry run)" : ""));
  }, []);

  app.command("run-due", "", "Run all due archiving jobs", (CliContext c) {
    return show(c, engine.invoke(c.request, "RunDueJobs", Json.emptyObject));
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

///
unittest {
  Json[string] o;
  o["storage"] = "memory";
  o["workerIntervalSeconds"] = 5;
  auto container = new DrContainer(loadDrConfig(o, "/nonexistent"));
  container.events.log = false;
  string out_;
  auto cli = buildDrCli(container, (string s) @safe { out_ ~= s; });

  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["list", "DataSubjects"]) == 0 && cli.run(["stats"]) == 0);
  out_ = "";
  assert(cli.run(["check", "--simulate", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["simulated"].get!bool, out_);
  assert(cli.run(["check", "erp"]) == 0 && cli.run(["check", "nope"]) == 1);
  assert(cli.run(["simulate", "sales", "2020-01-31"]) == 0);
  assert(cli.run(["activate", "vendors"]) == 1); // its legal ground has no residence rule yet
  assert(cli.run(["hold", "ds-1002", "Audit 2026"]) == 0 && cli.run(["hold", "ds-1002", "--release"]) == 0);
  out_ = "";
  assert(cli.run(["erase", "ds-3002", "--json"]) == 0, out_);
  assert(parseJsonString(out_)["status"].get!string == "completed", out_);
  assert(cli.run(["process"]) == 0 && cli.run(["run-job", "job-crm-dryrun"]) == 0 && cli.run(["run-due"]) == 0);
  assert(cli.run(["sets"]) == 0 && cli.run(["metadata"]) == 0 && cli.run(["config"]) == 0);
  assert(cli.run(["create", "Users", `--data={"id":"ops","password":"long enough pw","scopes":["Manage"]}`]) == 0, out_);
  assert(cli.run(["passwd", "ops", "another long pw"]) == 0);
  assert(cli.run(["token", "ops"]) == 1); // authMode open: no issuer
}

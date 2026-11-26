/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus autoscaler commands.
module uim.platform.application_autoscaler.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-application-autoscaler-cli";

CliApplication buildAasCli(AasContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;
  auto app = new CliApplication(cliProgram,
    "Application Autoscaler administration: bindings, policies with rules and schedules, metrics, evaluations, "
    ~ "manual scaling and the scaling history", output);
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

  int invokeOn(CliContext c, string action, string what) {
    auto r = engine.invoke(c.request, action, Json(["id": Json(c.operand(0, what))]));
    auto status = "status" in r && r["status"].type == Json.Type.string ? r["status"].get!string : "done";
    return c.done(r, what ~ " '" ~ r["id"].get!string ~ "': " ~ status);
  }

  int evaluation(CliContext c, Json r) {
    return c.done(r, format("%s: %s %d → %d (%s) — %s", r["bindingName"].get!string, r["status"].get!string,
      r["oldInstances"].get!long, r["newInstances"].get!long, r["trigger"].get!string, r["reason"].get!string));
  }

  app.command("stats", "", "Show the statistics of the tenant", (CliContext c) {
    auto row = engine.read(c.request, "Statistics", "");
    auto set = engine.model.find("Statistics");
    return c.emit(row, TextTable.keyValue(row, set.propertyNames, (string n) => set.labelOf(n)));
  }, []);
  app.command("seed", "", "Create the demo content in an empty tenant", (CliContext c) {
    auto r = engine.invoke(c.request, "SeedDemoData", Json.emptyObject);
    return c.done(r, format("Seeded tenant '%s': %d policies, %d rules, %d schedules, %d bindings, %d metric samples",
      c.request.tenantId, r["policies"].get!long, r["rules"].get!long, r["schedules"].get!long, r["bindings"].get!long,
      r["samples"].get!long));
  }, []);
  app.command("bind", "<app name> <app guid> [--policy=<policy>] [--instances=<n>] [--service-instance=<id>]",
    "Bind an application", (CliContext c) {
    auto p = Json(["name": Json(c.operand(0, "app name")), "appGuid": Json(c.operand(1, "app guid"))]);
    if (c.args.has("policy"))
      p["policyId"] = c.args.opt("policy");
    if (c.args.has("instances"))
      p["currentInstances"] = c.args.intOpt("instances", 1);
    if (c.args.has("service-instance"))
      p["serviceInstanceId"] = c.args.opt("service-instance");
    if (c.args.has("id"))
      p["id"] = c.args.opt("id");
    auto r = engine.create(c.request, "Bindings", p);
    return c.done(r, format("Bound '%s' as '%s' (%d instances)", r["name"].get!string, r["id"].get!string,
      r["currentInstances"].get!long));
  }, ["policy", "instances", "service-instance", "id"]);
  app.command("attach", "<binding> <policy>", "Attach a policy to a binding", (CliContext c) {
    auto r = engine.invoke(c.request, "AttachPolicy", Json(["id": Json(c.operand(0, "binding")),
        "policyId": Json(c.operand(1, "policy"))]));
    return c.done(r, "'" ~ r["name"].get!string ~ "' uses policy '" ~ r["policyName"].get!string ~ "'");
  }, []);
  app.command("detach", "<binding>", "Detach the policy of a binding", (CliContext c) {
    auto r = engine.invoke(c.request, "DetachPolicy", Json(["id": Json(c.operand(0, "binding"))]));
    return c.done(r, "'" ~ r["name"].get!string ~ "' has no policy now");
  }, []);
  app.command("suspend", "<binding>", "Suspend the autoscaling of a binding", (CliContext c) =>
    invokeOn(c, "SuspendBinding", "Binding"), []);
  app.command("resume", "<binding>", "Resume the autoscaling of a binding", (CliContext c) =>
    invokeOn(c, "ResumeBinding", "Binding"), []);
  app.command("metric", "<binding> <metric> <value> [--unit=<unit>] [--at=<ISO time>]", "Submit a metric value",
    (CliContext c) {
    auto p = Json(["bindingId": Json(c.operand(0, "binding")), "metricName": Json(c.operand(1, "metric"))]);
    p["value"] = c.operand(2, "value").to!double;
    if (c.args.has("unit"))
      p["unit"] = c.args.opt("unit");
    if (c.args.has("at"))
      p["measuredAt"] = c.args.opt("at");
    auto r = engine.create(c.request, "MetricSamples", p);
    return c.done(r, format("%s %s = %s %s", r["bindingName"].get!string, r["metricName"].get!string,
      fmtValue(r["value"].type == Json.Type.int_ ? r["value"].get!long : r["value"].get!double), r["unit"].get!string));
  }, ["unit", "at"]);
  app.command("simulate", "<binding> <metric> <value> [--seconds=<n>] [--step=<n>]",
    "Record a constant metric value over the last n seconds (default 180, every 30 s)", (CliContext c) {
    auto p = Json(["bindingId": Json(c.operand(0, "binding")), "metricName": Json(c.operand(1, "metric"))]);
    p["value"] = c.operand(2, "value").to!double;
    p["durationSeconds"] = c.args.intOpt("seconds", 180);
    p["stepSeconds"] = c.args.intOpt("step", 30);
    auto r = engine.invoke(c.request, "SimulateLoad", p);
    return c.done(r, format("%d samples of %s recorded", r["samples"].get!long, r["metricName"].get!string));
  }, ["seconds", "step"]);
  app.command("evaluate", "[<binding>]", "Evaluate one binding, or all autoscaled bindings", (CliContext c) {
    auto id = c.optionalOperand(0);
    if (id.length)
      return evaluation(c, engine.invoke(c.request, "EvaluateBinding", Json(["id": Json(id)])));
    return show(c, engine.invoke(c.request, "EvaluateAll", Json.emptyObject));
  }, []);
  app.command("preview", "<binding>", "Show what the scaling engine would decide now (nothing changes)", (CliContext c) =>
    evaluation(c, engine.invoke(c.request, "PreviewScaling", Json(["id": Json(c.operand(0, "binding"))]))), []);
  app.command("scale", "<binding> <instances> [<reason>]", "Scale a binding manually", (CliContext c) {
    auto p = Json(["id": Json(c.operand(0, "binding")), "instances": Json(c.operand(1, "instances").to!long)]);
    if (c.optionalOperand(2).length)
      p["reason"] = c.optionalOperand(2);
    return evaluation(c, engine.invoke(c.request, "ScaleBinding", p));
  }, []);
  app.command("history", "[<binding>]", "Show the scaling history (newest first)", (CliContext c) {
    string[string] options = ["$orderby": "createdAt desc", "$top": "50"];
    auto id = c.optionalOperand(0);
    if (id.length) {
      engine.read(c.request, "Bindings", id);
      options["$filter"] = "bindingId eq '" ~ id.replace("'", "''") ~ "'";
    }
    auto page = engine.query(c.request, "ScalingEvents", options);
    auto columns = ["createdAt", "bindingName", "trigger", "direction", "oldInstances", "newInstances", "status", "reason"];
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }, []);
  app.command("activate", "<policy>", "Activate a policy", (CliContext c) => invokeOn(c, "ActivatePolicy", "Policy"), []);
  app.command("deactivate", "<policy>", "Deactivate a policy", (CliContext c) => invokeOn(c, "DeactivatePolicy", "Policy"), []);
  app.command("rules", "<policy>", "List the rules of a policy", (CliContext c) {
    auto id = c.operand(0, "policy");
    engine.read(c.request, "Policies", id);
    auto page = engine.query(c.request, "Rules", ["$filter": "policyId eq '" ~ id.replace("'", "''") ~ "'"]);
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, ["id", "summary", "coolDownSeconds", "enabled"]));
  }, []);
  app.command("schedules", "<policy>", "List the schedules of a policy", (CliContext c) {
    auto id = c.operand(0, "policy");
    engine.read(c.request, "Policies", id);
    auto page = engine.query(c.request, "Schedules", ["$filter": "policyId eq '" ~ id.replace("'", "''") ~ "'"]);
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, ["id", "name", "kind", "summary", "enabled", "active"]));
  }, []);
  app.command("purge", "", "Remove metric samples and scaling events beyond their retention", (CliContext c) =>
    show(c, engine.invoke(c.request, "PurgeMetrics", Json.emptyObject)), []);
  app.command("capabilities", "", "Show what the service supports", (CliContext c) {
    c.print(capabilitiesJson(container.instances.mode, config.policy).toPrettyString ~ "\n");
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

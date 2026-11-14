/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// End-to-end test through the driving ports and the OData engine
/// (memory storage): the full AMS flow and the business rules.
module tests.lifecycle;

import uim.platform.authorization;

private RequestContext admin(string tenant = "t1") {
  RequestContext ctx;
  ctx.tenantId = tenant;
  ctx.userId = "admin";
  ctx.scopes = ["ams.Read", "ams.Admin", "ams.Check"];
  ctx.channel = "test";
  return ctx;
}

private int statusOf(scope void delegate() @safe dg) @safe {
  try
    dg();
  catch (EntitySetException e)
    return e.status;
  return 0;
}

unittest {
  Json[string] o;
  o["storage"] = "memory";
  auto c = new AuthorizationContainer(loadAuthorizationConfig(o, "/nonexistent"));
  auto engine = c.engine;
  engine.enforceScopes = true;
  auto ctx = admin();

  // application + API
  auto app = engine.create(ctx, "Applications", parseJsonString(`{"name": "travel", "description": "Travel expenses"}`));
  auto appId = app["id"].get!string;
  assert(statusOf(() { engine.create(ctx, "Applications", parseJsonString(`{"name": "travel"}`)); }) == 409);
  engine.create(ctx, "ApplicationApis", parseJsonString(`{"applicationId": "` ~ appId
      ~ `", "name": "trips", "endpoint": "/api/trips", "operations": ["Read", "Approve", "Read"]}`));
  assert(engine.read(ctx, "Applications", appId)["apiCount"].get!long == 1);

  // base policies are seeded idempotently and protected
  auto seed = Json.emptyObject;
  seed["application"] = "travel";
  assert(engine.invoke(ctx, "SeedBasePolicies", seed)["count"].get!long == 3);
  assert(engine.invoke(ctx, "SeedBasePolicies", seed)["count"].get!long == 3);
  auto adminPolicy = engine.query(ctx, "Policies", ["$filter": "name eq 'admin'"]).rows[0];
  assert(statusOf(() {
      engine.update(ctx, "Policies", adminPolicy["id"].get!string, parseJsonString(`{"resource": "Trip"}`));
    }) == 422);
  engine.update(ctx, "Policies", adminPolicy["id"].get!string, parseJsonString(`{"description": "Full access"}`));

  // custom policy with conditions
  auto approver = engine.create(ctx, "Policies", parseJsonString(`{"applicationId": "` ~ appId
      ~ `", "name": "approver-eu", "resource": "Trip", "action": "Approve",
         "conditions": "region in EU,CH; amount le 5000"}`));
  auto approverId = approver["id"].get!string;
  assert(approver["conditions"].get!string == "region in EU,CH; amount le 5000");
  assert(statusOf(() {
      engine.create(ctx, "Policies", parseJsonString(`{"applicationId": "` ~ appId
        ~ `", "name": "bad", "resource": "*", "action": "*", "conditions": "region like EU"}`));
    }) == 400);

  // assignments: user, group, duplicates, validity
  auto assign = engine.create(ctx, "Assignments", parseJsonString(`{"policyId": "` ~ approverId
      ~ `", "principalId": "erin"}`));
  assert(assign["principalType"].get!string == "user" && assign["effective"].get!bool);
  assert(statusOf(() {
      engine.create(ctx, "Assignments", parseJsonString(`{"policyId": "` ~ approverId ~ `", "principalId": "erin"}`));
    }) == 409);
  engine.create(ctx, "Assignments", parseJsonString(`{"policyId": "` ~ approverId
      ~ `", "principalType": "group", "principalId": "Managers", "validTo": "2020-01-01T00:00:00Z"}`));
  assert(statusOf(() {
      engine.create(ctx, "Assignments", parseJsonString(`{"policyId": "` ~ approverId
        ~ `", "principalId": "x", "validFrom": "2030-01-01T00:00:00Z", "validTo": "2029-01-01T00:00:00Z"}`));
    }) == 422);

  Json check(string principal, string groups, string attributes) {
    auto p = Json.emptyObject;
    p["principalId"] = principal;
    p["application"] = "travel";
    p["resource"] = "Trip";
    p["action"] = "approve";
    p["groups"] = groups;
    p["attributes"] = attributes;
    return engine.invoke(ctx, "EvaluateAuthorization", p);
  }

  assert(check("erin", "", "region=EU, amount=4999")["allowed"].get!bool);
  assert(!check("erin", "", "region=US, amount=10")["allowed"].get!bool);
  assert(!check("erin", "", "region=EU, amount=50000")["allowed"].get!bool); // numeric comparison
  assert(!check("frank", "Managers", "region=EU, amount=1")["allowed"].get!bool); // expired group assignment

  // disabled policies grant nothing and cannot be assigned
  auto id = Json.emptyObject;
  id["id"] = approverId;
  engine.invoke(ctx, "DisablePolicy", id);
  assert(!check("erin", "", "region=EU, amount=1")["allowed"].get!bool);
  assert(statusOf(() { engine.invoke(ctx, "DisablePolicy", id); }) == 422);
  assert(statusOf(() {
      engine.create(ctx, "Assignments", parseJsonString(`{"policyId": "` ~ approverId ~ `", "principalId": "gina"}`));
    }) == 422);
  engine.invoke(ctx, "EnablePolicy", id);

  // decision log + statistics
  auto stats = engine.read(ctx, "Statistics", "");
  assert(stats["decisions"].get!long == 5 && stats["permittedDecisions"].get!long == 1, stats.toString);
  assert(stats["policies"].get!long == 4 && stats["basePolicies"].get!long == 3);
  assert(stats["expiredAssignments"].get!long == 1);
  assert(engine.query(ctx, "Decisions", ["$filter": "allowed eq true"]).total == 1);
  assert(statusOf(() { engine.remove(ctx, "Decisions", "x"); }) == 405);

  // scopes: a reader may read but not change or check
  RequestContext reader = ctx;
  reader.scopes = ["ams.Read"];
  assert(engine.query(reader, "Policies", (string[string]).init).total == 4);
  assert(statusOf(() { engine.create(reader, "Applications", parseJsonString(`{"name": "x"}`)); }) == 403);
  assert(statusOf(() { check("erin", "", ""); }) == 0); // ctx still has Check
  assert(statusOf(() {
      auto p = Json.emptyObject;
      p["principalId"] = "erin";
      p["application"] = "travel";
      p["resource"] = "Trip";
      p["action"] = "Approve";
      engine.invoke(reader, "EvaluateAuthorization", p);
    }) == 403);

  // tenant isolation
  assert(engine.query(admin("other"), "Policies", (string[string]).init).total == 0);

  // cascade delete
  engine.remove(ctx, "Applications", appId);
  assert(engine.query(ctx, "Policies", (string[string]).init).total == 0);
  assert(engine.query(ctx, "Assignments", (string[string]).init).total == 0);
  assert(engine.query(ctx, "ApplicationApis", (string[string]).init).total == 0);
}

/// File storage is shared between containers (server, CLI, GUI).
unittest {
  import std.file : tempDir, remove, exists;
  import std.path : buildPath;

  auto file = buildPath(tempDir, "uim-authorization-test.json");
  if (exists(file))
    remove(file);
  scope (exit)
    if (exists(file))
      remove(file);

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto server = new AuthorizationContainer(loadAuthorizationConfig(o, "/nonexistent"));
  server.bootstrap(); // seeds "authorization-management" + base policies in tenant "default"
  auto cli = new AuthorizationContainer(loadAuthorizationConfig(o, "/nonexistent"));
  auto ctx = admin("default");
  assert(cli.engine.query(ctx, "Policies", (string[string]).init).total == 3);
  assert(cli.ports.applications.listApplications(TenantId("default"))[0].name == "authorization-management");
}

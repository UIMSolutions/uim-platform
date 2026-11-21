/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): governance through the
/// ports, management through the OData engine and controller, the REST
/// facade over vibe.d test requests, scopes and the file store.
module tests.architecture_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.architecture;

@safe:

version (unittest) {
  ArchitectureContainer newContainer(IDocumentStore store = null) {
    Json[string] o;
    o["storage"] = "memory";
    auto c = new ArchitectureContainer(loadArchitectureConfig(o, "/nonexistent"), store, new FixedClock(nowStdTime()));
    c.events.log = false;
    return c;
  }

  RequestContext admin(string tenant = "default") {
    return RequestContext.local(tenant, "test", "admin");
  }

  int statusOf(scope void delegate() @safe dg) {
    try
      dg();
    catch (EntitySetException e)
      return e.status;
    return 0;
  }

  /// One REST call through the router; returns the parsed body (or the raw text in "text").
  Json call(URLRouter router, string method, string path, Json body, out int status, string tenant = "default") @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = "application/json";
    headers["X-Tenant-Id"] = tenant;
    auto text = body.type == Json.Type.undefined ? "" : body.toString;
    auto req = createTestHTTPServerRequest(URL("http://localhost" ~ path), httpMethodFromString(method), headers,
      createMemoryStream(cast(ubyte[]) text.dup, false));
    auto output = createMemoryOutputStream();
    auto res = createTestHTTPServerResponse(output, null, TestHTTPResponseMode.bodyOnly);
    router.handleRequest(req, res);
    status = res.statusCode;
    auto answer = cast(string) output.data;
    if (answer.strip.length == 0)
      return Json(null);
    try
      return parseJsonString(answer);
    catch (Exception)
      return Json(["text": Json(answer)]);
  }
}

/// Seed → statistics, gaps, orphans, phase-out risks and impact are consistent.
unittest {
  auto c = newContainer();
  auto t = TenantId("default");
  auto seeded = c.ports.seeder.seed(t, UserId("admin"));
  assert(seeded.blocks == 18 && seeded.relationships == 15);

  auto s = c.ports.analysis.statistics(t);
  assert(s.blocks == 18 && s.relationships == 15 && s.ofKind(BlockKind.solution) == 5);
  assert(s.gaps == 1 && s.coveragePercent == 80 && s.orphans == 2 && s.phaseOutRisks == 1);
  assert(c.ports.analysis.gaps(t)[0].id.value == "abb-analytics");
  assert(c.ports.analysis.phaseOutRisks(t)[0].block.id.value == "sbb-legacy-crm");

  // PostgreSQL → Order Service → (Order Capture ABB, Order to Cash, Event Mesh → Sales Cloud → ...)
  auto impact = c.ports.analysis.impact(t, BuildingBlockId("tbb-postgres"));
  auto ids = impact.impacted.map!(i => i.id.value).array;
  assert(impact.direct == 1 && ids[0] == "sbb-order-service", ids.join(","));
  assert(ids.canFind("bbb-order-to-cash") && ids.canFind("abb-order-capture") && ids.canFind("sbb-sales-cloud"));
  assert(failsWith(ArchitectureErrorKind.notFound, () { c.ports.analysis.impact(t, BuildingBlockId("nope")); }));

  // tenant isolation
  assert(c.ports.analysis.statistics(TenantId("other")).blocks == 0);
}

/// Governance: lifecycle transitions, deletion rules, realization and relationship rules.
unittest {
  auto c = newContainer();
  auto t = TenantId("default");
  auto actor = UserId("ea");
  c.ports.seeder.seed(t, actor);

  // closing the gap: a new SBB realizing the analytics ABB
  CreateBlockRequest r;
  r.tenantId = t;
  r.actor = actor;
  r.kind = "SBB";
  r.values.name = "SAP Analytics Cloud";
  r.values.realizesId = "abb-analytics";
  r.values.tags = ["Analytics", "analytics", " SaaS "];
  auto sac = c.ports.blocks.createBlock(r);
  assert(sac.id.value.startsWith("sbb-") && sac.status == LifecycleStatus.proposed && sac.tags == ["analytics", "saas"]);
  assert(c.ports.analysis.statistics(t).gaps == 0);

  // an SBB cannot realize an SBB, an ABB cannot realize at all
  r.values.realizesId = "sbb-sales-cloud";
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.blocks.createBlock(r); }));
  r.kind = "architecture";
  r.values.realizesId = "abb-crm";
  assert(failsWith(ArchitectureErrorKind.invalid, () { c.ports.blocks.createBlock(r); }));
  r.id = "abb-crm";
  r.values.realizesId.nullify();
  assert(failsWith(ArchitectureErrorKind.conflict, () { c.ports.blocks.createBlock(r); }));

  // lifecycle
  auto id = sac.id;
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.blocks.changeStatus(t, id, "active", actor); }));
  c.ports.blocks.changeStatus(t, id, "approved", actor);
  c.ports.blocks.changeStatus(t, id, "active", actor);
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.blocks.deleteBlock(t, id, actor); }));
  c.ports.blocks.changeStatus(t, id, "deprecated", actor);
  c.ports.blocks.changeStatus(t, id, "retired", actor);
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.blocks.changeStatus(t, id, "active", actor); }));
  assert(c.ports.analysis.statistics(t).gaps == 1); // retired SBBs do not close gaps

  // relationships: rules and duplicates
  CreateRelationshipRequest rel;
  rel.tenantId = t;
  rel.actor = actor;
  rel.type = "serving";
  rel.sourceId = "tbb-kyma";
  rel.targetId = "sbb-order-service";
  auto created = c.ports.relationships.createRelationship(rel);
  assert(failsWith(ArchitectureErrorKind.conflict, () { c.ports.relationships.createRelationship(rel); }));
  rel.sourceId = "dbb-customer"; // data objects do not serve
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.relationships.createRelationship(rel); }));
  rel.sourceId = id.value; // retired
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { c.ports.relationships.createRelationship(rel); }));
  rel.sourceId = "missing";
  assert(failsWith(ArchitectureErrorKind.invalid, () { c.ports.relationships.createRelationship(rel); }));
  RelationshipFilter f;
  f.blockId = "tbb-kyma";
  assert(c.ports.relationships.listRelationships(t, f).length == 1);

  // deleting an ABB clears the realizations and removes its relationships
  c.ports.blocks.changeStatus(t, BuildingBlockId("abb-crm"), "retired", actor);
  c.ports.blocks.deleteBlock(t, BuildingBlockId("abb-crm"), actor);
  assert(c.ports.blocks.getBlock(t, BuildingBlockId("sbb-sales-cloud")).realizesId.isNull);
  f.blockId = "abb-crm";
  assert(c.ports.relationships.listRelationships(t, f).length == 0);

  // filters
  BlockFilter bf;
  bf.kind = "TBB";
  assert(c.ports.blocks.listBlocks(t, bf).length == 3);
  bf.kind = "";
  bf.search = "Runtime";
  assert(c.ports.blocks.listBlocks(t, bf).length == 2);
  bf.search = "";
  bf.tag = "Security";
  assert(c.ports.blocks.listBlocks(t, bf).length == 2);
  assert(created.id.value.startsWith("rel-"));
}

/// OData engine: payload validation, immutable status, actions, scopes, $metadata.
unittest {
  auto c = newContainer();
  auto e = c.engine;
  auto ctx = admin();
  e.invoke(ctx, "SeedDemoData", Json.emptyObject);
  assert(statusOf(() { e.invoke(ctx, "SeedDemoData", Json.emptyObject); }) == 409);

  auto row = e.create(ctx, "BuildingBlocks", parseJsonString(`{"id":"tbb-gateway","kind":"technology",
    "name":"API Gateway","elementType":"technology-interface","tags":["Gateway"],"validUntil":"2030-12-31"}`));
  assert(row["kindAbbreviation"].get!string == "TBB" && row["elementType"].get!string == "TechnologyInterface");
  assert(row["domain"].get!string == "technology" && row["validUntil"].get!string == "2030-12-31");
  assert(row["status"].get!string == "proposed");

  // status is immutable on PATCH — lifecycle goes through ChangeStatus
  auto patched = e.update(ctx, "BuildingBlocks", "tbb-gateway", parseJsonString(`{"status":"active","owner":"platform"}`));
  assert(patched["status"].get!string == "proposed" && patched["owner"].get!string == "platform");
  auto changed = e.invoke(ctx, "ChangeStatus", parseJsonString(`{"id":"tbb-gateway","status":"approved"}`));
  assert(changed["previousStatus"].get!string == "proposed" && changed["status"].get!string == "approved");
  assert(statusOf(() { e.invoke(ctx, "ChangeStatus", parseJsonString(`{"id":"tbb-gateway","status":"retired-ish"}`)); }) == 400);
  assert(statusOf(() { e.invoke(ctx, "ChangeStatus", parseJsonString(`{"id":"tbb-gateway","status":"deprecated"}`)); }) == 422);

  // validation errors map to 400 / 404 / 422
  assert(statusOf(() { e.create(ctx, "BuildingBlocks", parseJsonString(`{"kind":"data","name":"X","elementType":"Node"}`)); }) == 400);
  assert(statusOf(() { e.create(ctx, "BuildingBlocks", parseJsonString(`{"kind":"pattern","name":"X"}`)); }) == 400);
  assert(statusOf(() { e.create(ctx, "BuildingBlocks", parseJsonString(`{"kind":"data","name":"X","unknown":1}`)); }) == 400);
  assert(statusOf(() { e.read(ctx, "BuildingBlocks", "nope"); }) == 404);
  assert(statusOf(() { e.remove(ctx, "BuildingBlocks", "tbb-btp-cf"); }) == 422); // active
  assert(statusOf(() { e.create(ctx, "Gaps", Json.emptyObject); }) == 405);

  // query options
  string[string] q = ["$filter": "kind eq 'solution' and status eq 'active'"];
  assert(e.query(ctx, "BuildingBlocks", q).total == 3);
  assert(e.query(ctx, "ElementTypes", ["$filter": "domain eq 'motivation'"]).total == 10);
  auto crm = e.read(ctx, "BuildingBlocks", "abb-crm");
  assert(crm["realizedByCount"].get!long == 2 && crm["relationshipCount"].get!long == 1);
  assert(e.read(ctx, "BuildingBlocks", "sbb-sales-cloud")["realizesName"].get!string == "Customer Relationship Management");
  auto rels = e.query(ctx, "Relationships", ["$filter": "targetId eq 'bbb-order-to-cash'"]);
  assert(rels.total == 4 && rels.rows[0]["targetName"].get!string == "Order to Cash");
  assert(e.read(ctx, "Statistics", "")["coveragePercent"].get!long == 80);
  assert(e.invoke(ctx, "AnalyzeImpact", parseJsonString(`{"id":"sbb-xsuaa"}`)).length >= 2);
  auto export_ = e.invoke(ctx, "ExportArchiMate", Json.emptyObject);
  assert(export_["elements"].get!long == 19 && export_["content"].get!string.canFind(`xsi:type="Realization"`));

  // scopes: Read is not enough to write, Manage is not enough to govern
  e.enforceScopes = true;
  auto reader = admin();
  reader.scopes = ["arch.Read"];
  assert(statusOf(() { e.query(reader, "BuildingBlocks", q); }) == 0);
  assert(statusOf(() { e.create(reader, "BuildingBlocks", parseJsonString(`{"kind":"data","name":"Y"}`)); }) == 403);
  reader.scopes ~= "arch.Manage";
  assert(statusOf(() { e.invoke(reader, "ChangeStatus", parseJsonString(`{"id":"tbb-gateway","status":"active"}`)); }) == 403);
  reader.scopes ~= "arch.Govern";
  assert(e.invoke(reader, "ChangeStatus", parseJsonString(`{"id":"tbb-gateway","status":"active"}`))["status"].get!string == "active");
  e.enforceScopes = false;

  // OData controller: $metadata with annotations, entity requests, action
  auto odata = new ODataController(e, "/odata/v4/architecture");
  auto md = odata.dispatch(ctx, ODataHttpRequest("GET", "/$metadata"));
  assert(md.status == 200 && md.body.canFind(`<EntitySet Name="BuildingBlocks"`) && md.body.canFind("ChangeStatus"));
  auto one = odata.dispatch(ctx, ODataHttpRequest("GET", "/BuildingBlocks('abb-iam')"));
  assert(one.status == 200 && parseJsonString(one.body)["name"].get!string == "Identity and Access Management", one.body);
  ODataHttpRequest impactReq;
  impactReq.method = "POST";
  impactReq.path = "/AnalyzeImpact";
  impactReq.body = `{"id":"tbb-btp-cf"}`;
  impactReq.headers["content-type"] = "application/json";
  auto impact = odata.dispatch(ctx, impactReq);
  assert(impact.status == 200 && parseJsonString(impact.body)["value"].length >= 1, impact.body);
}

/// REST facade (/api/v1) incl. the field names of the 1.x API.
unittest {
  auto c = newContainer();
  auto router = new URLRouter;
  auto security = configureSecurity(c.config);
  new ArchitectureApiController(c.engine, security, c.config.apiPath).registerRoutes(router);
  new ArchitectureHealthController(c.config, security.mode).registerRoutes(router, c.config.apiPath);
  int status;

  assert(call(router, "GET", "/health", Json.init, status)["status"].get!string == "UP" && status == 200);
  call(router, "POST", "/api/v1/seed", Json.emptyObject, status);
  assert(status == 201);

  // 1.x payload: type / lifecycleState
  auto created = call(router, "POST", "/api/v1/building-blocks", parseJsonString(`{"type":"technology",
    "name":"Central API Gateway","owner":"platform-team","lifecycleState":"identified","versionLabel":"1.0.0",
    "tags":["gateway","security"]}`), status);
  assert(status == 201 && created["kind"].get!string == "technology" && created["status"].get!string == "proposed", created.toString);
  auto id = created["id"].get!string;

  assert(call(router, "GET", "/api/v1/building-blocks?kind=SBB&status=active", Json.init, status)["count"].get!long == 3);
  assert(call(router, "GET", "/api/v1/building-blocks/types/technology", Json.init, status)["count"].get!long == 4);
  assert(call(router, "GET", "/api/v1/building-blocks?tag=security", Json.init, status)["count"].get!long == 3);

  // PATCH with a different status is refused, the status endpoint applies the transition
  call(router, "PATCH", "/api/v1/building-blocks/" ~ id, parseJsonString(`{"status":"active"}`), status);
  assert(status == 400);
  auto changed = call(router, "PATCH", "/api/v1/building-blocks/" ~ id, parseJsonString(`{"description":"Ingress"}`), status);
  assert(status == 200 && changed["description"].get!string == "Ingress");
  auto transitioned = call(router, "POST", "/api/v1/building-blocks/" ~ id ~ "/status", parseJsonString(`{"status":"approved"}`),
    status);
  assert(status == 200 && transitioned["status"].get!string == "approved");
  auto bad = call(router, "POST", "/api/v1/building-blocks/" ~ id ~ "/status", parseJsonString(`{"status":"deprecated"}`), status);
  assert(status == 422 && bad["error"]["code"].get!string == "BusinessRuleViolation");

  // relationships
  auto rel = call(router, "POST", "/api/v1/relationships", parseJsonString(`{"type":"serving","sourceId":"` ~ id
      ~ `","targetId":"sbb-order-service"}`), status);
  assert(status == 201 && rel["targetName"].get!string == "Order Service", rel.toString);
  assert(call(router, "GET", "/api/v1/building-blocks/" ~ id ~ "/relationships", Json.init, status)["count"].get!long == 1);
  assert(call(router, "GET", "/api/v1/relationships?type=access", Json.init, status)["count"].get!long == 3);
  assert(call(router, "GET", "/api/v1/building-blocks/" ~ id ~ "/impact", Json.init, status)["count"].get!long >= 3);
  call(router, "DELETE", "/api/v1/relationships/" ~ rel["id"].get!string, Json.init, status);
  assert(status == 204);

  // analysis, catalogue, export
  assert(call(router, "GET", "/api/v1/analysis/statistics", Json.init, status)["blocks"].get!long == 19);
  assert(call(router, "GET", "/api/v1/analysis/gaps", Json.init, status)["count"].get!long == 1);
  assert(call(router, "GET", "/api/v1/analysis/phase-out-risks", Json.init, status)["value"][0]["id"].get!string == "sbb-legacy-crm");
  assert(call(router, "GET", "/api/v1/element-types", Json.init, status)["count"].get!long == 60);
  auto xml = call(router, "GET", "/api/v1/export/archimate?modelName=Test", Json.init, status);
  assert(status == 200 && xml["text"].get!string.canFind("<name xml:lang=\"en\">Test</name>"));

  // errors
  call(router, "GET", "/api/v1/building-blocks/nope", Json.init, status);
  assert(status == 404);
  call(router, "DELETE", "/api/v1/building-blocks/tbb-btp-cf", Json.init, status);
  assert(status == 422);
  assert(call(router, "GET", "/api/v1/building-blocks", Json.init, status, "t2")["count"].get!long == 0); // tenant header
  call(router, "DELETE", "/api/v1/building-blocks/" ~ id, Json.init, status);
  assert(status == 204); // approved → deletable
}

/// File store: content survives a restart (server, CLI and GUI share the snapshot).
unittest {
  import std.file : tempDir, remove, exists;
  import std.path : buildPath;

  auto file = buildPath(tempDir, "uim-architecture-test-" ~ newResourceId() ~ ".json");
  scope (exit)
    if (exists(file))
      remove(file);
  {
    auto c = newContainer(new FileDocumentStore(file));
    c.ports.seeder.seed(TenantId("default"), UserId("admin"));
  }
  auto reopened = newContainer(new FileDocumentStore(file));
  assert(reopened.ports.analysis.statistics(TenantId("default")).blocks == 18);
  assert(reopened.ports.blocks.getBlock(TenantId("default"), BuildingBlockId("dbb-customer")).dataClassification == "confidential");
}

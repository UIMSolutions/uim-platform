/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Integration tests across the layers (dub test): the document flow
/// through the ports (seed → upload → extraction → review → confirmation →
/// training), the business rules of schemas, templates, documents, clients
/// and training jobs, the REST API and the OData endpoint over vibe.d test
/// requests, the built-in JWT login with scopes, the CLI and the batching
/// file store.
module tests.document_ai_flows;

import vibe.http.router : URLRouter;
import vibe.http.server : createTestHTTPServerRequest, createTestHTTPServerResponse, TestHTTPResponseMode;
import vibe.http.common : httpMethodFromString;
import vibe.inet.message : InetHeaderMap;
import vibe.inet.url : URL;
import vibe.stream.memory : createMemoryOutputStream, createMemoryStream;
import uim.platform.document_ai;

@safe:

version (unittest) {
  /// 2026-11-25T00:00:00Z — every test runs on the same day.
  long t0() {
    return parseIsoTime("2026-11-25");
  }

  DaiContainer newContainer(Json[string] extra = null, StorageSetup storage = StorageSetup.init) {
    Json[string] o;
    o["storage"] = "memory";
    o["workerIntervalSeconds"] = 5; // documents stay pending until processed (no worker runs in tests)
    o["passwordIterations"] = 1000;
    foreach (k, v; extra)
      o[k] = v;
    auto c = new DaiContainer(loadDaiConfig(o, "/nonexistent"), storage, new ManualClock(t0));
    c.events.log = false;
    return c;
  }

  /// One HTTP call through the router; text bodies are sent as is.
  Json call(URLRouter router, string method, string path, Json body, out int status, string contentType = "application/json",
    string text = "", string bearer = "") @trusted {
    InetHeaderMap headers;
    headers["Content-Type"] = contentType;
    if (bearer.length)
      headers["Authorization"] = "Bearer " ~ bearer;
    auto payload = text.length ? text : body.type == Json.Type.undefined ? "" : body.toString;
    auto req = createTestHTTPServerRequest(URL("http://localhost" ~ path), httpMethodFromString(method), headers,
      createMemoryStream(cast(ubyte[]) payload.dup, false));
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
      return Json(answer);
  }

  URLRouter routerOf(DaiContainer c) {
    c.engine.enforceScopes = c.security.requireAuthentication; // as in app.d
    auto router = new URLRouter;
    new DaiHealthController(c.config, c.security.mode, c.extraction.mode, c.metrics).registerRoutes(router, c.config.apiPath);
    new AuthController(c.ports, c.security).registerRoutes(router);
    new DaiApiController(c.engine, c.security, "/api/v1", "2.0.0", 4 * 1024 * 1024,
      capabilitiesJson(c.extraction.mode, c.config.policy)).registerRoutes(router);
    auto odata = new ODataController(c.engine, "/odata/v4/document-ai");
    odata.verifier = c.security.verifier;
    odata.requireAuthentication = c.security.requireAuthentication;
    odata.registerRoutes(router);
    return router;
  }

  auto t = TenantId("default");
  auto actor = UserId("tester");

  AiDocument upload(DaiContainer c, string fileName, string type = "supplier-invoice", string[] labels = null,
    string client = "", string schema = "") {
    DocumentInput i;
    i.fileName = fileName;
    i.documentTypeId = type;
    i.labels = labels;
    i.clientId = client;
    i.schemaId = schema;
    return c.ports.documents.create(createCommand(t, actor, "", i));
  }

  /// A valid sample value of a type (what a reviewer types in).
  string sampleValue(string valueType) {
    switch (valueType) {
    case "number":
      return "1";
    case "date":
      return "2026-11-25";
    case "currency":
      return "EUR";
    case "boolean":
      return "true";
    default:
      return "x";
    }
  }

  ExtractedField valueNamed(DaiContainer c, DocumentId doc, string name) {
    foreach (f; c.ports.fields.listOf(t, doc))
      if (f.name == name && f.rowIndex == 0)
        return f;
    assert(false, "no value " ~ name);
  }
}

/// The document flow through the driving ports.
unittest {
  auto c = newContainer();
  auto seeded = seedDemoData(c.ports, t, actor);
  assert(seeded.schemas == 3 && seeded.schemaFields == 29 && seeded.documents == 6 && seeded.documentTypes == 3, seeded.to!string);
  assert(failsWith(DaiErrorKind.conflict, () { seedDemoData(c.ports, t, actor); }));

  // confirmed demo documents, matched with the supplier master data
  auto acme = c.ports.documents.get(t, DocumentId("doc-acme-0042"));
  assert(acme.status == DocumentStatus.confirmed && acme.extractionMethod == ExtractionMethod.templateBased, acme.to!string);
  assert(acme.matchStatus == MatchStatus.matched && acme.matchedEnrichmentId.value == "sup-acme", acme.to!string);
  assert(valueNamed(c, acme.id, "documentNumber").value == "INV-2026-0042");
  assert(acme.lineItemCount >= 1 && acme.extractedFieldCount == 10 + 5 * acme.lineItemCount, acme.to!string);
  auto globex = c.ports.documents.get(t, DocumentId("doc-globex-1126"));
  assert(globex.correctedFieldCount >= 1 && valueNamed(c, globex.id, "dueDate").value == "2026-12-26");
  assert(valueNamed(c, globex.id, "dueDate").corrected && globex.matchedEnrichmentId.value == "sup-globex");

  // the worker extracts the pending document
  auto pending = c.ports.documents.get(t, DocumentId("doc-initech-0007"));
  assert(pending.status == DocumentStatus.pending && pending.extractedFieldCount == 0);
  auto run = c.ports.documents.processPending(t, UserId(workerActor));
  assert(run.documents == 1 && run.extracted == 1 && run.failed == 0, run.to!string);
  pending = c.ports.documents.get(t, pending.id);
  assert(pending.status == DocumentStatus.done && pending.matchedEnrichmentId.value == "sup-initech", pending.to!string);
  assert(pending.attempts == 1 && pending.processedAt == t0);

  // review: correct a value, the summary follows; confirm
  auto gross = valueNamed(c, pending.id, "grossAmount");
  assert(failsWith(DaiErrorKind.invalid, () { c.ports.fields.correct(t, gross.id, "12,50", actor); }));
  auto corrected = c.ports.fields.correct(t, gross.id, "1250.00", actor);
  assert(corrected.corrected && corrected.originalValue == gross.value && corrected.confidence == 1.0);
  assert(c.ports.documents.get(t, pending.id).correctedFieldCount == 1);
  auto supplier = valueNamed(c, pending.id, "senderName");
  c.ports.fields.correct(t, supplier.id, "Unknown Supplier Ltd", actor);
  assert(c.ports.documents.get(t, pending.id).matchStatus != MatchStatus.matched); // matching follows the corrected value
  c.ports.fields.correct(t, supplier.id, "Initech AG", actor);
  auto number = valueNamed(c, pending.id, "documentNumber");
  c.ports.fields.correct(t, number.id, "", actor); // a required value removed …
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.documents.confirm(t, pending.id, actor); }));
  c.ports.fields.correct(t, number.id, "INV-7", actor); // … and given again
  auto confirmed = c.ports.documents.confirm(t, pending.id, actor);
  assert(confirmed.status == DocumentStatus.confirmed && confirmed.confirmedBy == "tester");
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.fields.correct(t, gross.id, "1", actor); }));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.documents.extract(t, pending.id, actor); }));

  // training: 4 confirmed invoices → running → completed by the worker
  auto job = c.ports.trainingJobs.start(t, TrainingJobId("train-invoice"), actor);
  assert(job.status == TrainingJobStatus.running && job.documentCount == 4, job.to!string);
  assert(c.ports.trainingJobs.advance(t, actor) == 0); // training time not over
  (cast(ManualClock) c.clock).advance(31);
  assert(c.ports.trainingJobs.advance(t, actor) == 1);
  job = c.ports.trainingJobs.get(t, job.id);
  assert(job.status == TrainingJobStatus.completed && job.modelVersion == "invoice-v1" && job.accuracy > 0.8
      && job.accuracy < 1.0, job.to!string);

  auto s = c.ports.statistics.compute(t);
  assert(s.documents == 6 && s.confirmedDocuments == 4 && s.pendingDocuments == 0 && s.bestAccuracy == cast(long)(
      job.accuracy * 100 + 0.5), s.to!string);
  assert(s.activeSchemas == 2 && s.templates == 1 && s.matchedDocuments >= 4 && s.correctionRate > 0, s.to!string);
}

/// Business rules of schemas, documents, clients and training jobs.
unittest {
  auto c = newContainer();
  seedDemoData(c.ports, t, actor);

  // uploads
  assert(failsWith(DaiErrorKind.invalid, () { upload(c, "picture.gif"); }));
  assert(failsWith(DaiErrorKind.ruleViolation, () { upload(c, "order.png", "purchase-order"); })); // type accepts pdf, docx, xlsx
  assert(failsWith(DaiErrorKind.invalid, () { upload(c, "r.png", "receipt"); })); // no default schema
  assert(failsWith(DaiErrorKind.ruleViolation, () { upload(c, "r.png", "receipt", null, "", "receipt"); })); // draft schema
  assert(failsWith(DaiErrorKind.notFound, () { upload(c, "x.pdf", "nope"); }));
  assert(failsWith(DaiErrorKind.invalid, () { upload(c, "x.pdf", "supplier-invoice", ["novalue"]); }));
  DocumentInput fr;
  fr.fileName = "facture.pdf";
  fr.documentTypeId = "supplier-invoice";
  fr.language = "fr";
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.documents.create(createCommand(t, actor, "", fr)); }));

  // a failing extraction, reprocess, reject
  auto bad = upload(c, "blurred.jpg", "supplier-invoice", ["simulate=failure"]);
  bad = c.ports.documents.extract(t, bad.id, actor);
  assert(bad.status == DocumentStatus.failed && bad.errorMessage.canFind("OCR"), bad.to!string);
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.documents.confirm(t, bad.id, actor); }));
  assert(failsWith(DaiErrorKind.invalid, () { c.ports.documents.reject(t, bad.id, " ", actor); }));
  bad = c.ports.documents.reject(t, bad.id, "Unreadable scan", actor);
  assert(bad.status == DocumentStatus.rejected);
  assert(failsWith(DaiErrorKind.ruleViolation, () {
      c.ports.documents.update(updateCommand(t, actor, bad.id.value, DocumentInput.init, "language"));
    }));

  // changing the extraction setup makes extracted values outdated
  auto doc = c.ports.documents.extract(t, upload(c, "again.pdf").id, actor);
  assert(doc.status == DocumentStatus.done);
  DocumentInput change;
  change.extractionMethod = "generativeAi";
  doc = c.ports.documents.update(updateCommand(t, actor, doc.id.value, change, "extractionMethod"));
  assert(doc.status == DocumentStatus.pending && doc.extractionMethod == ExtractionMethod.generativeAi);
  DocumentInput rename;
  rename.fileName = "other.pdf";
  assert(failsWith(DaiErrorKind.invalid, () { c.ports.documents.update(updateCommand(t, actor, doc.id.value, rename, "fileName")); }));
  c.ports.documents.remove(t, doc.id, actor);
  assert(c.repositories.extractedFields.countByReference(t, "documentId", doc.id.value) == 0);

  // schemas: frozen fields, copies, activation, deletion
  SchemaFieldInput f;
  f.schemaId = "invoice";
  f.name = "iban";
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.schemaFields.create(createCommand(t, actor, "", f)); }));
  auto v2 = c.ports.schemas.copy(t, SchemaId("invoice"), "invoice-v2", actor);
  assert(v2.status == SchemaStatus.draft && v2.version_ == 2 && v2.basedOnId.value == "invoice");
  assert(c.ports.schemaFields.listOf(t, v2.id).length == 15);
  f.schemaId = "invoice-v2";
  c.ports.schemaFields.create(createCommand(t, actor, "", f));
  assert(failsWith(DaiErrorKind.conflict, () { c.ports.schemaFields.create(createCommand(t, actor, "", f)); }));
  f.name = "1bad";
  assert(failsWith(DaiErrorKind.invalid, () { c.ports.schemaFields.create(createCommand(t, actor, "", f)); }));
  c.ports.schemas.activate(t, v2.id, actor);
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.schemas.activate(t, v2.id, actor); }));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.schemas.remove(t, SchemaId("invoice"), actor); }));
  SchemaInput empty;
  empty.name = "Empty";
  auto e = c.ports.schemas.create(createCommand(t, actor, "empty", empty));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.schemas.activate(t, e.id, actor); })); // no header field
  c.ports.schemas.remove(t, e.id, actor);
  c.ports.schemas.deprecate(t, SchemaId("invoice"), actor);
  assert(failsWith(DaiErrorKind.ruleViolation, () { upload(c, "late.pdf"); })); // default schema deprecated

  // templates need an active schema of the document's schema
  TemplateInput ti;
  ti.schemaId = "receipt";
  ti.name = "Taxi receipts";
  auto tpl = c.ports.templates.create(createCommand(t, actor, "taxi", ti));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.templates.activate(t, tpl.id, actor); }));
  TemplateInput change2;
  change2.schemaId = "invoice";
  assert(failsWith(DaiErrorKind.invalid, () { c.ports.templates.update(updateCommand(t, actor, "taxi", change2, "schemaId")); }));

  // client quota and uniqueness
  ClientInput ci;
  ci.name = "Pilot";
  ci.documentQuota = 1;
  c.ports.clients.create(createCommand(t, actor, "pilot", ci));
  assert(failsWith(DaiErrorKind.conflict, () { c.ports.clients.create(createCommand(t, actor, "pilot2", ci)); }));
  upload(c, "one.pdf", "supplier-invoice", null, "pilot", "invoice-v2");
  assert(failsWith(DaiErrorKind.ruleViolation, () { upload(c, "two.pdf", "supplier-invoice", null, "pilot", "invoice-v2"); }));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.clients.remove(t, ClientId("pilot"), actor); }));

  // training needs enough confirmed documents; one running job per schema
  TrainingJobInput ji;
  ji.schemaId = "purchase-order";
  ji.name = "PO model";
  auto po = c.ports.trainingJobs.create(createCommand(t, actor, "train-po", ji));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.trainingJobs.start(t, po.id, actor); }));
  c.ports.trainingJobs.start(t, TrainingJobId("train-invoice"), actor);
  ji.schemaId = "invoice";
  ji.name = "Second";
  auto second = c.ports.trainingJobs.create(createCommand(t, actor, "train-2", ji));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.trainingJobs.start(t, second.id, actor); }));
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.trainingJobs.remove(t, TrainingJobId("train-invoice"), actor); }));
  c.ports.trainingJobs.cancel(t, TrainingJobId("train-invoice"), actor);
  assert(c.ports.trainingJobs.start(t, second.id, actor).status == TrainingJobStatus.running);
}

/// Inline extraction (workerIntervalSeconds 0) and enrichment matching.
unittest {
  auto c = newContainer(["workerIntervalSeconds": Json(0), "minConfidence": Json(0.99)]);
  seedDemoData(c.ports, t, actor);
  auto doc = upload(c, "inline.pdf", "supplier-invoice", ["senderName=globex gmbh", "senderCity=HAMBURG"]);
  assert(doc.status == DocumentStatus.done && doc.matchedEnrichmentId.value == "sup-globex", doc.to!string);
  assert(doc.needsReview && doc.lowConfidenceCount > 0); // threshold 0.99: almost everything needs a look
}

/// REST and OData adapters (authMode open).
unittest {
  auto c = newContainer();
  auto router = routerOf(c);
  int status;
  enum api = "/api/v1/document-ai";

  auto health = call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200 && health["status"].get!string == "UP" && health["extraction"].get!string == "simulate");
  call(router, "POST", api ~ "/demo-data", Json.emptyObject, status);
  assert(status == 200);
  auto caps = call(router, "GET", api ~ "/capabilities", Json.undefined, status);
  assert(status == 200 && caps["fileTypes"].length == 6);

  auto docs = call(router, "GET", api ~ "/documents?$orderby=fileName", Json.undefined, status);
  assert(status == 200 && docs["count"].get!long == 6, docs.toString);
  auto uploaded = call(router, "POST", api ~ "/documents", Json(["fileName": Json("rest-invoice.pdf"),
      "documentTypeId": Json("supplier-invoice"), "fileSize": Json(1234), "labels": Json([Json("senderName=ACME Corp")])]),
    status);
  assert(status == 201 && uploaded["status"].get!string == "pending" && uploaded["schemaName"].get!string == "Supplier Invoice",
    uploaded.toString);
  auto id = uploaded["id"].get!string;
  auto extracted = call(router, "POST", api ~ "/documents/" ~ id ~ "/extract", Json.emptyObject, status);
  assert(status == 200 && extracted["status"].get!string == "done" && extracted["confidencePercent"].get!long > 0,
    extracted.toString);
  auto values = call(router, "GET", api ~ "/documents/" ~ id ~ "/fields", Json.undefined, status);
  assert(status == 200 && values["count"].get!long == extracted["extractedFieldCount"].get!long, values.toString);
  auto first = values["resources"][0];
  assert(first["rowIndex"].get!long == 0 && first["name"].get!string == "documentNumber", first.toString);
  foreach (row; values["resources"].get!(Json[])) // fill what the engine did not find
    if (row["missing"].get!bool)
      call(router, "POST", api ~ "/extracted-fields/" ~ row["id"].get!string ~ "/correct",
        Json(["value": Json(sampleValue(row["valueType"].get!string))]), status);
  auto fixed = call(router, "POST", api ~ "/extracted-fields/" ~ first["id"].get!string ~ "/correct",
    Json(["value": Json("INV-REST-1")]), status);
  assert(status == 200 && fixed["corrected"].get!bool && fixed["value"].get!string == "INV-REST-1", fixed.toString);
  auto patched = call(router, "PATCH", api ~ "/extracted-fields/" ~ first["id"].get!string, Json(["value": Json("INV-REST-2")]),
    status);
  assert(status == 200 && patched["value"].get!string == "INV-REST-2", patched.toString);
  call(router, "POST", api ~ "/documents/" ~ id ~ "/reject", Json.emptyObject, status);
  assert(status == 400); // reason is required
  auto done = call(router, "POST", api ~ "/documents/" ~ id ~ "/confirm", Json.emptyObject, status);
  assert(status == 200 && done["status"].get!string == "confirmed", done.toString);
  call(router, "POST", api ~ "/documents/" ~ id ~ "/confirm", Json.emptyObject, status);
  assert(status == 422);
  call(router, "GET", api ~ "/documents/nope/fields", Json.undefined, status);
  assert(status == 404);
  call(router, "POST", api ~ "/extracted-fields", Json.emptyObject, status);
  assert(status == 405);

  auto schemaFields = call(router, "GET", api ~ "/schemas/invoice/fields", Json.undefined, status);
  assert(status == 200 && schemaFields["count"].get!long == 15 && schemaFields["resources"][0]["fieldScope"].get!string
      == "header", schemaFields.toString);
  auto field = call(router, "POST", api ~ "/schema-fields", Json(["schemaId": Json("invoice"), "name": Json("iban")]), status);
  assert(status == 422 && field["error"]["message"].get!string.canFind("frozen"), field.toString);
  auto processed = call(router, "POST", api ~ "/documents/process", Json.emptyObject, status);
  assert(status == 200 && processed["extracted"].get!long == 1, processed.toString);
  auto review = call(router, "GET", api ~ "/review", Json.undefined, status);
  assert(status == 200, review.toString);
  auto stats = call(router, "GET", api ~ "/statistics", Json.undefined, status);
  assert(status == 200 && stats["documents"].get!long == 7 && stats["confirmedDocuments"].get!long == 4, stats.toString);
  auto meta = call(router, "GET", api ~ "/meta", Json.undefined, status);
  assert(status == 200 && meta["documentStatuses"].length == 5);

  // OData: $metadata, query options, actions, PATCH
  auto metadata = call(router, "GET", "/odata/v4/document-ai/$metadata", Json.undefined, status);
  assert(status == 200 && metadata.get!string.canFind(`EntitySet Name="ExtractedFields"`), metadata.to!string[0 .. 200]);
  auto low = call(router, "GET", "/odata/v4/document-ai/Documents?$filter=status%20eq%20'confirmed'&$count=true",
    Json.undefined, status);
  assert(status == 200 && low["@odata.count"].get!long == 4, low.toString);
  auto tpl = call(router, "POST", "/odata/v4/document-ai/Templates", Json(["schemaId": Json("invoice"),
      "name": Json("Globex layout"), "senderName": Json("Globex GmbH")]), status);
  assert(status == 201 && tpl["status"].get!string == "draft", tpl.toString);
  auto active = call(router, "POST", "/odata/v4/document-ai/ActivateTemplate", Json(["id": tpl["id"]]), status);
  assert(status == 200 && active["status"].get!string == "active", active.toString);
  auto training = call(router, "POST", "/odata/v4/document-ai/StartTraining", Json(["id": Json("train-invoice")]), status);
  assert(status == 200 && training["status"].get!string == "running" && training["progressPercent"].get!long == 0,
    training.toString);
  auto stat = call(router, "GET", "/odata/v4/document-ai/Statistics", Json.undefined, status);
  assert(status == 200 && stat["runningTrainingJobs"].get!long == 1, stat.toString);
  auto renamed = call(router, "PATCH", "/odata/v4/document-ai/Schemas('receipt')", Json(["description": Json("Receipts"),
      "status": Json("active")]), status); // status is computed → ignored
  assert(status == 200 || status == 204, renamed.toString);
  assert(c.ports.schemas.get(t, SchemaId("receipt")).status == SchemaStatus.draft);
}

/// Built-in login (authMode jwt): tokens and the scopes Read / Process / Manage / Admin.
unittest {
  auto c = newContainer(["authMode": Json("jwt"), "jwtSecret": Json("0123456789abcdef0123456789abcdef"),
      "maxFailedLogins": Json(3)]);
  assert(c.security.mode == "jwt" && c.security.loginEnabled && !c.security.generatedSecret);
  assert(c.ports.users.ensureAdministrator(t, "admin", "admin password 1"));
  auto router = routerOf(c);
  int status;
  enum api = "/api/v1/document-ai";

  auto cfg = call(router, "GET", "/auth/config", Json.undefined, status);
  assert(status == 200 && cfg["loginRequired"].get!bool && cfg["mode"].get!string == "jwt");
  call(router, "GET", api ~ "/documents", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/odata/v4/document-ai/Documents", Json.undefined, status);
  assert(status == 401);
  call(router, "GET", "/health", Json.undefined, status);
  assert(status == 200); // probes stay public
  call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("wrong")]), status);
  assert(status == 401);

  auto login = call(router, "POST", "/auth/login", Json(["username": Json("admin"), "password": Json("admin password 1")]), status);
  assert(status == 200 && login["scope"].get!string == "Read Process Manage Admin", login.toString);
  auto admin = login["access_token"].get!string;
  call(router, "POST", api ~ "/demo-data", Json.emptyObject, status, "application/json", "", admin);
  assert(status == 200);
  auto me = call(router, "GET", "/auth/me", Json.undefined, status, "application/json", "", admin);
  assert(status == 200 && me["user"].get!string == "admin" && me["scopes"].length == 4);

  // a clerk (Process) and a viewer (Read)
  call(router, "POST", "/odata/v4/document-ai/Users", Json(["id": Json("clerk"), "password": Json("clerk password"),
      "scopes": Json([Json("Process")])]), status, "application/json", "", admin);
  assert(status == 201);
  call(router, "POST", "/odata/v4/document-ai/Users", Json(["id": Json("viewer"), "password": Json("viewer password"),
      "scopes": Json([Json("Read")])]), status, "application/json", "", admin);
  assert(status == 201);
  auto cl = call(router, "POST", "/auth/login", Json.undefined, status, "application/x-www-form-urlencoded",
    "username=clerk&password=clerk%20password", "");
  assert(status == 200 && cl["scope"].get!string == "Read Process", cl.toString);
  auto clerk = cl["access_token"].get!string;
  auto viewer = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("viewer password")]),
    status)["access_token"].get!string;

  // Read
  call(router, "GET", "/odata/v4/document-ai/ExtractedFields", Json.undefined, status, "application/json", "", viewer);
  assert(status == 200);
  call(router, "POST", "/odata/v4/document-ai/ExtractDocument", Json(["id": Json("doc-initech-0007")]), status,
    "application/json", "", viewer);
  assert(status == 403);
  // Process: documents and values, but not schemas or users
  auto extracted = call(router, "POST", "/odata/v4/document-ai/ExtractDocument", Json(["id": Json("doc-initech-0007")]),
    status, "application/json", "", clerk);
  assert(status == 200 && extracted["status"].get!string == "done", extracted.toString);
  auto up = call(router, "POST", api ~ "/documents", Json(["fileName": Json("clerk.pdf"), "documentTypeId": Json("supplier-invoice")]),
    status, "application/json", "", clerk);
  assert(status == 201 && up["createdBy"].get!string == "clerk", up.toString);
  call(router, "POST", api ~ "/schemas/receipt/activate", Json.emptyObject, status, "application/json", "", clerk);
  assert(status == 403);
  call(router, "DELETE", api ~ "/enrichment-data/sup-acme", Json.undefined, status, "application/json", "", clerk);
  assert(status == 403);
  call(router, "GET", "/odata/v4/document-ai/Users", Json.undefined, status, "application/json", "", clerk);
  assert(status == 403);

  // password change, lockout, the last administrator
  call(router, "POST", "/auth/password", Json(["currentPassword": Json("viewer password"), "newPassword": Json("a better password")]),
    status, "application/json", "", viewer);
  assert(status == 204);
  foreach (_; 0 .. 3)
    call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("nope")]), status);
  auto locked = call(router, "POST", "/auth/login", Json(["username": Json("viewer"), "password": Json("a better password")]), status);
  assert(status == 401 && locked["error"]["message"].get!string.canFind("locked"), locked.toString);
  assert(failsWith(DaiErrorKind.ruleViolation, () { c.ports.users.deleteUser(t, UserAccountId("admin"), UserId("clerk")); }));
  call(router, "GET", api ~ "/documents", Json.undefined, status, "application/json", "", admin[0 .. $ - 2] ~ "xx");
  assert(status == 401); // tampered token
}

/// The command line adapter.
unittest {
  auto c = newContainer(["workerIntervalSeconds": Json(0)]);
  string out_;
  auto cli = buildDaiCli(c, (string s) @safe { out_ ~= s; });
  assert(cli.run(["seed", "--json"]) == 0, out_);
  assert(cli.run(["seed"]) == 1); // not empty → conflict
  assert(cli.run(["stats"]) == 0 && cli.run(["list", "Documents"]) == 0 && cli.run(["sets"]) == 0);
  out_ = "";
  assert(cli.run(["values", "doc-acme-0042", "--json"]) == 0, out_);
  assert(parseJsonString(out_).length >= 15, out_);
  out_ = "";
  assert(cli.run(["upload", "cli-invoice.pdf", "--type=supplier-invoice", "--label=senderName=ACME Corp", "--json"]) == 0, out_);
  auto doc = parseJsonString(out_);
  assert(doc["status"].get!string == "done" && doc["matchedEnrichmentId"].get!string == "sup-acme", out_);
  assert(cli.run(["upload", "bad.gif"]) == 1);
  out_ = "";
  assert(cli.run(["values", doc["id"].get!string, "--json"]) == 0, out_);
  foreach (row; parseJsonString(out_).get!(Json[]))
    if (row["missing"].get!bool)
      assert(cli.run(["correct", row["id"].get!string, sampleValue(row["valueType"].get!string)]) == 0);
  assert(cli.run(["fields", "invoice"]) == 0 && cli.run(["review"]) == 0 && cli.run(["process"]) == 0);
  assert(cli.run(["copy", "invoice", "invoice-v2"]) == 0 && cli.run(["activate", "invoice-v2"]) == 0);
  assert(cli.run(["confirm", doc["id"].get!string]) == 0 && cli.run(["confirm", doc["id"].get!string]) == 1);
  assert(cli.run(["train", "train-invoice"]) == 0 && cli.run(["cancel", "train-invoice"]) == 0);
  assert(cli.run(["reject", "doc-scan-0193", "duplicate"]) == 0 && cli.run(["capabilities"]) == 0 && cli.run(["config"]) == 0);
  assert(cli.run(["token", "admin"]) == 1); // authMode open: no issuer
}

/// Batching file store: an extraction (document + all values) writes the
/// snapshot once; a second container (the CLI next to the server) sees the data.
unittest {
  import std.file : tempDir, exists, rmdirRecurse;
  import std.path : buildPath, dirName;
  import std.uuid : randomUUID;

  auto file = buildPath(tempDir, "uim-dai-" ~ randomUUID.toString, "data.json");
  scope (exit)
    if (exists(dirName(file)))
      rmdirRecurse(dirName(file));
  auto storage = createStorage("file", file);
  auto c = newContainer(null, storage);
  seedDemoData(c.ports, t, actor);
  auto store = cast(BatchingFileDocumentStore) storage.store;
  auto before = store.flushes;
  c.ports.documents.extract(t, DocumentId("doc-initech-0007"), actor);
  assert(store.flushes == before + 1, (store.flushes - before).to!string);

  Json[string] o;
  o["storage"] = "file";
  o["dataFile"] = file;
  auto other = new DaiContainer(loadDaiConfig(o, "/nonexistent"));
  other.events.log = false;
  assert(other.ports.documents.list(t).length == 6);
  assert(other.ports.documents.get(t, DocumentId("doc-initech-0007")).status == DocumentStatus.done);
}

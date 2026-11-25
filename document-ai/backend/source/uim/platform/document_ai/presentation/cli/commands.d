/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Command line adapter: the generic, model driven entity commands of
/// uim-platform:service (sets, metadata, list, count, get, create, update,
/// delete, invoke) plus document AI commands.
module uim.platform.document_ai.presentation.cli.commands;

import uim.platform.service.presentation.cli;
import uim.platform.service.presentation.odata;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string cliProgram = "uim-document-ai-cli";

CliApplication buildDaiCli(DaiContainer container, CliOutput output = null) {
  auto engine = container.engine;
  auto config = container.config;
  auto app = new CliApplication(cliProgram,
    "Document AI administration: upload and extract documents, review and correct values, confirm, schemas and their "
    ~ "fields, templates, document types, enrichment data, clients and training jobs", output);
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
    return c.done(r, format("Seeded tenant '%s': %d clients, %d document types, %d schemas (%d fields), %d templates, "
      ~ "%d enrichment records, %d documents, %d training jobs", c.request.tenantId, r["clients"].get!long,
      r["documentTypes"].get!long, r["schemas"].get!long, r["schemaFields"].get!long, r["templates"].get!long,
      r["enrichmentRecords"].get!long, r["documents"].get!long, r["trainingJobs"].get!long));
  }, []);
  app.command("upload", "<file name> [--type=<document type>] [--schema=<schema>] [--template=<template>] "
    ~ "[--client=<client>] [--language=<code>] [--pages=<n>] [--size=<bytes>] [--label=k=v,…] [--extract]",
    "Register an uploaded document (metadata) and optionally extract it right away", (CliContext c) {
    auto p = Json(["fileName": Json(c.operand(0, "file name"))]);
    foreach (option, member; ["type": "documentTypeId", "schema": "schemaId", "template": "templateId",
        "client": "clientId", "language": "language", "method": "extractionMethod"])
      if (c.args.has(option))
        p[member] = c.args.opt(option);
    if (c.args.has("pages"))
      p["pageCount"] = c.args.intOpt("pages", 1);
    if (c.args.has("size"))
      p["fileSize"] = c.args.intOpt("size", 0);
    if (c.args.has("label"))
      p["labels"] = texts(c.args.opt("label").split(",").map!(s => s.strip).filter!(s => s.length > 0).array);
    auto r = engine.create(c.request, "Documents", p);
    if (c.args.has("extract") && r["status"].get!string == "pending")
      r = engine.invoke(c.request, "ExtractDocument", Json(["id": r["id"]]));
    return c.done(r, format("Document '%s' (%s): %s, %d values, confidence %d %%", r["id"].get!string,
      r["fileName"].get!string, r["status"].get!string, r["extractedFieldCount"].get!long, r["confidencePercent"].get!long));
  }, ["type", "schema", "template", "client", "language", "method", "pages", "size", "label", "extract"]);
  app.command("extract", "<document>", "Run the extraction of a document (again)",
    (CliContext c) => invokeOn(c, "ExtractDocument", "Document"), []);
  app.command("process", "", "Extract all pending documents now", (CliContext c) =>
    show(c, engine.invoke(c.request, "ProcessPendingDocuments", Json.emptyObject)), []);
  app.command("values", "<document>", "List the extracted values of a document", (CliContext c) {
    auto id = c.operand(0, "document");
    engine.read(c.request, "Documents", id);
    auto page = engine.query(c.request, "ExtractedFields", ["$filter": "documentId eq '" ~ id.replace("'", "''") ~ "'",
        "$orderby": "rowIndex,sequenceNumber"]);
    auto columns = ["rowIndex", "id", "label", "value", "confidencePercent", "confidenceLevel", "corrected", "missing"];
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }, []);
  app.command("correct", "<value id> <value>", "Correct an extracted value ('-' clears it)", (CliContext c) {
    auto value = c.operand(1, "value");
    auto r = engine.invoke(c.request, "CorrectField", Json(["id": Json(c.operand(0, "value id")),
        "value": Json(value == "-" ? "" : value)]));
    return c.done(r, "'" ~ r["label"].get!string ~ "' = '" ~ r["value"].get!string ~ "'");
  }, []);
  app.command("confirm", "<document>", "Confirm the values of a document", (CliContext c) =>
    invokeOn(c, "ConfirmDocument", "Document"), []);
  app.command("reject", "<document> <reason>", "Reject a document", (CliContext c) {
    c.operand(1, "reason");
    return invokeOn(c, "RejectDocument", "Document", ["reason"]);
  }, []);
  app.command("review", "", "List the documents that need a review", (CliContext c) {
    auto page = engine.query(c.request, "Documents", ["$filter": "needsReview eq true", "$orderby": "createdAt"]);
    auto columns = ["id", "fileName", "documentTypeName", "confidencePercent", "lowConfidenceCount", "matchStatus"];
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }, []);
  app.command("activate", "<schema>", "Activate a schema", (CliContext c) => invokeOn(c, "ActivateSchema", "Schema"), []);
  app.command("deprecate", "<schema>", "Deprecate a schema", (CliContext c) => invokeOn(c, "DeprecateSchema", "Schema"), []);
  app.command("copy", "<schema> [<new id>]", "Copy a schema as a new draft version",
    (CliContext c) => invokeOn(c, "CopySchema", "Schema", ["newId"]), []);
  app.command("fields", "<schema>", "List the fields of a schema", (CliContext c) {
    auto id = c.operand(0, "schema");
    engine.read(c.request, "Schemas", id);
    auto page = engine.query(c.request, "SchemaFields", ["$filter": "schemaId eq '" ~ id.replace("'", "''") ~ "'",
        "$orderby": "fieldScope,sequenceNumber"]);
    auto columns = ["fieldScope", "sequenceNumber", "id", "name", "label", "valueType", "required"];
    return c.emit(Json(page.rows), TextTable.fromRows(page.rows, columns));
  }, []);
  app.command("template-activate", "<template>", "Activate a template",
    (CliContext c) => invokeOn(c, "ActivateTemplate", "Template"), []);
  app.command("template-deactivate", "<template>", "Deactivate a template",
    (CliContext c) => invokeOn(c, "DeactivateTemplate", "Template"), []);
  app.command("train", "<training job>", "Start a training job", (CliContext c) =>
    invokeOn(c, "StartTraining", "Training job"), []);
  app.command("cancel", "<training job>", "Cancel a training job", (CliContext c) =>
    invokeOn(c, "CancelTraining", "Training job"), []);
  app.command("capabilities", "", "Show what the service supports", (CliContext c) {
    c.print(capabilitiesJson(container.extraction.mode, config.policy).toPrettyString ~ "\n");
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

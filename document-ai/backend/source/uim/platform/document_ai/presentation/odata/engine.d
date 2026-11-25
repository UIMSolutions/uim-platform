/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Binds the EDM model to the driving ports. The resulting engine serves
/// the OData controller, the REST API, the CLI and the GUI.
module uim.platform.document_ai.presentation.odata.engine;

import uim.platform.service.presentation.odata;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// IEntitySetProvider that translates DocumentAiException.
class PortProvider : IEntitySetProvider {
  protected DelegateEntitySetProvider inner;

  this(DelegateEntitySetProvider inner) {
    this.inner = inner;
  }

  Json[] list(const RequestContext ctx) {
    return translated!(Json[])(() => inner.list(ctx));
  }

  Json get(const RequestContext ctx, string key) {
    return translated!Json(() => inner.get(ctx, key));
  }

  Json create(const RequestContext ctx, Json payload) {
    return translated!Json(() => inner.create(ctx, payload));
  }

  Json update(const RequestContext ctx, string key, Json payload) {
    return translated!Json(() => inner.update(ctx, key, payload));
  }

  void remove(const RequestContext ctx, string key) {
    translated!void(() { inner.remove(ctx, key); });
  }
}

/// A provider over a maintained resource port; rows(t, entities) builds the
/// rows of many entities at once (derived facts are computed once per call).
PortProvider resourceProvider(TEntity, TId, TInput, R)(IManageResource!(TEntity, TId, TInput) port, R rows) {
  auto p = new DelegateEntitySetProvider;
  p.onList = (const RequestContext ctx) => rows(tenantOf(ctx), port.list(tenantOf(ctx)));
  p.onGet = (const RequestContext ctx, string key) => rows(tenantOf(ctx), [port.get(tenantOf(ctx), TId(key))])[0];
  p.onCreate = (const RequestContext ctx, Json payload) => rows(tenantOf(ctx), [
    port.create(createCommandOf!TInput(ctx, payload))
  ])[0];
  p.onUpdate = (const RequestContext ctx, string key, Json payload) => rows(tenantOf(ctx), [
    port.update(updateCommandOf!TInput(ctx, key, payload))
  ])[0];
  p.onRemove = (const RequestContext ctx, string key) { port.remove(tenantOf(ctx), TId(key), actorOf(ctx)); };
  return new PortProvider(p);
}

ODataEngine documentAiEngine(DaiPorts ports, IClock clock, DaiPolicy policy, size_t maxPageSize = 0) {
  auto engine = new ODataEngine(documentAiModel());
  auto threshold = policy.minConfidence;

  // ── lookups ─────────────────────────────────────────────────────────────
  string[string] names(R)(R items) {
    string[string] n;
    foreach (i; items)
      n[i.id.value] = i.name;
    return n;
  }

  long[string] countBy(alias key, R)(R items) {
    long[string] c;
    foreach (i; items) {
      auto k = key(i);
      if (k.length)
        c[k]++;
    }
    return c;
  }

  // ── row builders with derived facts ─────────────────────────────────────
  Json[] documentRows(TenantId t, AiDocument[] docs) {
    auto clients = names(ports.clients.list(t));
    auto types = names(ports.documentTypes.list(t));
    auto schemas = names(ports.schemas.list(t));
    auto templates = names(ports.templates.list(t));
    auto records = names(ports.enrichmentData.list(t));
    return docs.map!(d => documentRow(d, DocumentNames(clients.get(d.clientId.value, ""),
        types.get(d.documentTypeId.value, ""), schemas.get(d.schemaId.value, ""), templates.get(d.templateId.value, ""),
        records.get(d.matchedEnrichmentId.value, "")), threshold)).array;
  }

  Json[] fieldRows(TenantId t, ExtractedField[] fields) {
    AiDocument[string] docs;
    foreach (f; fields)
      if (f.documentId.value !in docs)
        docs[f.documentId.value] = ports.documents.get(t, f.documentId);
    return fields.map!(f => extractedFieldRow(f, docs[f.documentId.value].fileName,
        cast(string) docs[f.documentId.value].status, threshold)).array;
  }

  Json[] schemaRows(TenantId t, Schema[] schemas) {
    SchemaFacts[string] facts;
    foreach (s; schemas) {
      SchemaFacts f;
      foreach (sf; ports.schemaFields.listOf(t, s.id))
        if (sf.fieldScope == FieldScope.header)
          f.headerFields++;
        else
          f.lineItemFields++;
      facts[s.id.value] = f;
    }
    foreach (d; ports.documents.list(t))
      if (auto f = d.schemaId.value in facts)
        f.documents++;
    return schemas.map!(s => schemaRow(s, facts[s.id.value])).array;
  }

  Json[] schemaFieldRows(TenantId t, SchemaField[] fields) {
    string[string] statuses;
    foreach (s; ports.schemas.list(t))
      statuses[s.id.value] = cast(string) s.status;
    return fields.map!(f => schemaFieldRow(f, statuses.get(f.schemaId.value, ""))).array;
  }

  Json[] templateRows(TenantId t, DocumentTemplate[] templates) {
    auto schemas = names(ports.schemas.list(t));
    auto docs = countBy!(d => d.templateId.value)(ports.documents.list(t));
    return templates.map!(tpl => templateRow(tpl, schemas.get(tpl.schemaId.value, ""), docs.get(tpl.id.value, 0))).array;
  }

  Json[] documentTypeRows(TenantId t, DocumentType[] types) {
    auto clients = names(ports.clients.list(t));
    auto schemas = names(ports.schemas.list(t));
    auto docs = countBy!(d => d.documentTypeId.value)(ports.documents.list(t));
    return types.map!(dt => documentTypeRow(dt, clients.get(dt.clientId.value, ""), schemas.get(dt.defaultSchemaId.value, ""),
        docs.get(dt.id.value, 0))).array;
  }

  Json[] enrichmentRows(TenantId t, EnrichmentData[] records) {
    auto matched = countBy!(d => d.matchStatus == MatchStatus.matched ? d.matchedEnrichmentId.value : "")(ports.documents.list(t));
    return records.map!(e => enrichmentRow(e, matched.get(e.id.value, 0))).array;
  }

  Json[] clientRows(TenantId t, Client[] clients) {
    auto counts = ports.clients.documentCounts(t);
    return clients.map!(c => clientRow(c, counts.get(c.id.value, 0))).array;
  }

  Json[] trainingRows(TenantId t, TrainingJob[] jobs) {
    auto schemas = names(ports.schemas.list(t));
    auto at = clock.now;
    auto duration = ports.trainingJobs.durationSeconds;
    return jobs.map!(j => trainingJobRow(j, schemas.get(j.schemaId.value, ""), at, duration)).array;
  }

  // ── entity sets ─────────────────────────────────────────────────────────
  engine.provide("Documents", resourceProvider(
      cast(IManageResource!(AiDocument, DocumentId, DocumentInput)) ports.documents, &documentRows));
  engine.provide("Schemas", resourceProvider(
      cast(IManageResource!(Schema, SchemaId, SchemaInput)) ports.schemas, &schemaRows));
  engine.provide("SchemaFields", resourceProvider(
      cast(IManageResource!(SchemaField, SchemaFieldId, SchemaFieldInput)) ports.schemaFields, &schemaFieldRows));
  engine.provide("Templates", resourceProvider(
      cast(IManageResource!(DocumentTemplate, TemplateId, TemplateInput)) ports.templates, &templateRows));
  engine.provide("DocumentTypes", resourceProvider(
      cast(IManageResource!(DocumentType, DocumentTypeId, DocumentTypeInput)) ports.documentTypes, &documentTypeRows));
  engine.provide("EnrichmentData", resourceProvider(
      cast(IManageResource!(EnrichmentData, EnrichmentDataId, EnrichmentDataInput)) ports.enrichmentData, &enrichmentRows));
  engine.provide("Clients", resourceProvider(
      cast(IManageResource!(Client, ClientId, ClientInput)) ports.clients, &clientRows));
  engine.provide("TrainingJobs", resourceProvider(
      cast(IManageResource!(TrainingJob, TrainingJobId, TrainingJobInput)) ports.trainingJobs, &trainingRows));

  auto fields = new DelegateEntitySetProvider;
  fields.onList = (const RequestContext ctx) => fieldRows(tenantOf(ctx), ports.fields.list(tenantOf(ctx)));
  fields.onGet = (const RequestContext ctx, string key) => fieldRows(tenantOf(ctx), [
    ports.fields.get(tenantOf(ctx), ExtractedFieldId(key))
  ])[0];
  fields.onUpdate = (const RequestContext ctx, string key, Json p) {
    auto current = ports.fields.get(tenantOf(ctx), ExtractedFieldId(key));
    if (!has(p, "value"))
      return fieldRows(tenantOf(ctx), [current])[0];
    auto changed = ports.fields.correct(tenantOf(ctx), current.id, textOf(p, "value"), actorOf(ctx));
    return fieldRows(tenantOf(ctx), [changed])[0];
  };
  engine.provide("ExtractedFields", new PortProvider(fields));

  auto users = new DelegateEntitySetProvider;
  users.onList = (const RequestContext ctx) {
    auto at = clock.now;
    return ports.users.listUsers(tenantOf(ctx)).map!(u => userRow(u, at)).array;
  };
  users.onGet = (const RequestContext ctx, string key) => userRow(ports.users.getUser(tenantOf(ctx), UserAccountId(key)), clock.now);
  users.onCreate = (const RequestContext ctx, Json p) => userRow(ports.users.createUser(createUserRequest(ctx, p)), clock.now);
  users.onUpdate = (const RequestContext ctx, string key, Json p) => userRow(
    ports.users.updateUser(updateUserRequest(ctx, key, p)), clock.now);
  users.onRemove = (const RequestContext ctx, string key) {
    ports.users.deleteUser(tenantOf(ctx), UserAccountId(key), actorOf(ctx));
  };
  engine.provide("Users", new PortProvider(users));

  auto statistics = new DelegateEntitySetProvider;
  statistics.keyProperty = "tenantId";
  statistics.onGet = (const RequestContext ctx, string key) => statisticsRow(ports.statistics.compute(tenantOf(ctx)));
  engine.provide("Statistics", new PortProvider(statistics));

  // ── actions ─────────────────────────────────────────────────────────────
  void action(string name, Json delegate(const RequestContext, Json) @safe handler) {
    engine.handle(name, (const RequestContext ctx, Json p) => translated!Json(() => handler(ctx, p)));
  }

  Json documentOne(const RequestContext ctx, AiDocument d) {
    return documentRows(tenantOf(ctx), [d])[0];
  }

  Json schemaOne(const RequestContext ctx, Schema s) {
    return schemaRows(tenantOf(ctx), [s])[0];
  }

  Json templateOne(const RequestContext ctx, DocumentTemplate tpl) {
    return templateRows(tenantOf(ctx), [tpl])[0];
  }

  Json trainingOne(const RequestContext ctx, TrainingJob j) {
    return trainingRows(tenantOf(ctx), [j])[0];
  }

  action("ExtractDocument", (ctx, p) => documentOne(ctx, ports.documents.extract(tenantOf(ctx), DocumentId(idParam(p)),
      actorOf(ctx))));
  action("ConfirmDocument", (ctx, p) => documentOne(ctx, ports.documents.confirm(tenantOf(ctx), DocumentId(idParam(p)),
      actorOf(ctx))));
  action("RejectDocument", (ctx, p) => documentOne(ctx, ports.documents.reject(tenantOf(ctx), DocumentId(idParam(p)),
      textOf(p, "reason"), actorOf(ctx))));
  action("ProcessPendingDocuments", (ctx, p) => processingRow(ports.documents.processPending(tenantOf(ctx), actorOf(ctx),
      policy.maxDocumentsPerRun)));
  action("CorrectField", (ctx, p) => fieldRows(tenantOf(ctx), [
      ports.fields.correct(tenantOf(ctx), ExtractedFieldId(idParam(p)), textOf(p, "value"), actorOf(ctx))
    ])[0]);
  action("ActivateSchema", (ctx, p) => schemaOne(ctx, ports.schemas.activate(tenantOf(ctx), SchemaId(idParam(p)), actorOf(ctx))));
  action("DeprecateSchema", (ctx, p) => schemaOne(ctx, ports.schemas.deprecate(tenantOf(ctx), SchemaId(idParam(p)), actorOf(ctx))));
  action("CopySchema", (ctx, p) => schemaOne(ctx, ports.schemas.copy(tenantOf(ctx), SchemaId(idParam(p)), textOf(p, "newId"),
      actorOf(ctx))));
  action("ActivateTemplate", (ctx, p) => templateOne(ctx, ports.templates.activate(tenantOf(ctx), TemplateId(idParam(p)),
      actorOf(ctx))));
  action("DeactivateTemplate", (ctx, p) => templateOne(ctx, ports.templates.deactivate(tenantOf(ctx), TemplateId(idParam(p)),
      actorOf(ctx))));
  action("StartTraining", (ctx, p) => trainingOne(ctx, ports.trainingJobs.start(tenantOf(ctx), TrainingJobId(idParam(p)),
      actorOf(ctx))));
  action("CancelTraining", (ctx, p) => trainingOne(ctx, ports.trainingJobs.cancel(tenantOf(ctx), TrainingJobId(idParam(p)),
      actorOf(ctx))));
  action("SeedDemoData", (ctx, p) => seedRow(seedDemoData(ports, tenantOf(ctx), actorOf(ctx))));

  engine.maxPageSize = maxPageSize;
  engine.verify();
  return engine;
}

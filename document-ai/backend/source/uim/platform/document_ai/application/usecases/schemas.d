/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Extraction schemas, their fields and templates.
///
/// Rules: fields can only be added, changed or removed while the schema is
/// a draft; field names are unique per schema and scope; activation needs a
/// header field; copies are new drafts with version + 1. Templates need an
/// active schema to be activated. Schemas in use cannot be deleted.
module uim.platform.document_ai.application.usecases.schemas;

import std.uni : icmp;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class ManageSchemasUseCase : ResourceInteractor!(Schema, SchemaId, SchemaInput), IManageSchemas {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(Schema, SchemaId) store() {
    return repos.schemas;
  }

  protected override string what() {
    return "Schema";
  }

  protected override string eventPrefix() {
    return "schema";
  }

  protected override SchemaInput toInput(const Schema e) {
    SchemaInput i;
    i.clientId = e.clientId.value;
    i.documentTypeId = e.documentTypeId.value;
    i.name = e.name;
    i.description = e.description;
    i.category = cast(string) e.category;
    i.supportedLanguages = e.supportedLanguages.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref Schema e, SchemaInput i, bool creating) {
    e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
    e.documentTypeId = DocumentTypeId(optionalReference!DocumentTypeId(repos.documentTypes, t, i.documentTypeId, "Document type"));
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.category = parseDomainEnum!DocumentCategory(i.category, "category");
    string[] languages;
    foreach (l; i.supportedLanguages)
      if (!languages.canFind(l.strip.toLower))
        languages ~= l.strip.toLower;
    e.supportedLanguages = languages;
  }

  protected override void beforeRemove(TenantId t, const Schema e, UserId actor) {
    auto what = "Schema '" ~ e.name ~ "'";
    requireUnused(what, repos.documents.countByReference(t, "schemaId", e.id.value), "documents");
    requireUnused(what, repos.templates.countByReference(t, "schemaId", e.id.value), "templates");
    requireUnused(what, repos.trainingJobs.countByReference(t, "schemaId", e.id.value), "training jobs");
    requireUnused(what, repos.documentTypes.countByReference(t, "defaultSchemaId", e.id.value), "document types (default schema)");
    foreach (f; repos.schemaFields.findByReference(t, "schemaId", e.id.value))
      repos.schemaFields.removeById(t, f.id);
  }

  Schema activate(TenantId t, SchemaId id, UserId actor) {
    auto s = get(t, id);
    auto fields = fieldsOf(t, id);
    s.activate(fields.length, fields.count!(f => f.fieldScope == FieldScope.header), now);
    stampUpdated(s, actor, now);
    repos.schemas.save(s);
    emit("schema.activated", t, id.value, Json(["fields": Json(fields.length)]));
    return s;
  }

  Schema deprecate(TenantId t, SchemaId id, UserId actor) {
    auto s = get(t, id);
    s.deprecate();
    stampUpdated(s, actor, now);
    repos.schemas.save(s);
    emit("schema.deprecated", t, id.value);
    return s;
  }

  Schema copy(TenantId t, SchemaId id, string newId, UserId actor) {
    auto source = get(t, id);
    auto target = idOrNew(newId, "Schema ID");
    if (repos.schemas.existsById(t, SchemaId(target)))
      throw DaiException.conflict("Schema '" ~ target ~ "' already exists");
    Schema s = source;
    stampCreated!(Schema, SchemaId)(s, t, actor, target, nextTime);
    s.status = SchemaStatus.draft;
    s.activatedAt = 0;
    s.basedOnId = source.id;
    int highest = source.version_;
    foreach (other; repos.schemas.findAll(t))
      if (icmp(other.name, source.name) == 0 && other.version_ > highest)
        highest = other.version_;
    s.version_ = highest + 1;
    s.validate();
    batch(() {
      repos.schemas.save(s);
      foreach (f; fieldsOf(t, id)) {
        SchemaField c = f;
        stampCreated!(SchemaField, SchemaFieldId)(c, t, actor, newResourceId(), nextTime);
        c.schemaId = s.id;
        repos.schemaFields.save(c);
      }
    });
    emit("schema.copied", t, target, Json(["from": Json(id.value)]));
    return s;
  }
}

class ManageSchemaFieldsUseCase : ResourceInteractor!(SchemaField, SchemaFieldId, SchemaFieldInput), IManageSchemaFields {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(SchemaField, SchemaFieldId) store() {
    return repos.schemaFields;
  }

  protected override string what() {
    return "Schema field";
  }

  protected override string eventPrefix() {
    return "schemaField";
  }

  protected override string[] immutableAttributes() {
    return ["schemaId"];
  }

  protected override SchemaFieldInput toInput(const SchemaField e) {
    SchemaFieldInput i;
    i.schemaId = e.schemaId.value;
    i.fieldScope = cast(string) e.fieldScope;
    i.sequenceNumber = e.sequenceNumber;
    i.name = e.name;
    i.label = e.label;
    i.valueType = cast(string) e.valueType;
    i.required = e.required;
    i.description = e.description;
    i.defaultValue = e.defaultValue;
    i.format = e.format;
    return i;
  }

  protected void requireDraft(TenantId t, SchemaId id) {
    auto s = schemaOf(t, id);
    if (!s.isDraft)
      throw DaiException.ruleViolation("The fields of schema '" ~ s.name ~ "' are frozen (status " ~ cast(string) s.status
          ~ ") — copy the schema to change them");
  }

  protected override void beforeUpdate(TenantId t, const SchemaField e) {
    requireDraft(t, e.schemaId);
  }

  protected override void fromInput(TenantId t, ref SchemaField e, SchemaFieldInput i, bool creating) {
    e.schemaId = SchemaId(i.schemaId.strip);
    if (creating)
      requireDraft(t, e.schemaId);
    e.fieldScope = parseDomainEnum!FieldScope(i.fieldScope, "field scope");
    e.sequenceNumber = i.sequenceNumber;
    e.name = i.name.strip;
    foreach (other; repos.schemaFields.findByReference(t, "schemaId", e.schemaId.value))
      if (other.id != e.id && other.fieldScope == e.fieldScope && icmp(other.name, e.name) == 0)
        throw DaiException.conflict("Schema '" ~ e.schemaId.value ~ "' already has a " ~ cast(string) e.fieldScope
            ~ " field '" ~ e.name ~ "'");
    e.label = i.label.strip.length ? i.label.strip : e.name;
    e.valueType = parseDomainEnum!FieldValueType(i.valueType, "value type");
    e.required = i.required;
    e.description = i.description.strip;
    e.defaultValue = i.defaultValue.strip;
    e.format = i.format.strip;
  }

  protected override void beforeRemove(TenantId t, const SchemaField e, UserId actor) {
    requireDraft(t, e.schemaId);
  }

  SchemaField[] listOf(TenantId t, SchemaId schema) {
    schemaOf(t, schema);
    return fieldsOf(t, schema);
  }
}

class ManageTemplatesUseCase : ResourceInteractor!(DocumentTemplate, TemplateId, TemplateInput), IManageTemplates {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected override IDaiRepository!(DocumentTemplate, TemplateId) store() {
    return repos.templates;
  }

  protected override string what() {
    return "Template";
  }

  protected override string eventPrefix() {
    return "template";
  }

  protected override string[] immutableAttributes() {
    return ["schemaId"];
  }

  protected override TemplateInput toInput(const DocumentTemplate e) {
    TemplateInput i;
    i.clientId = e.clientId.value;
    i.schemaId = e.schemaId.value;
    i.documentTypeId = e.documentTypeId.value;
    i.name = e.name;
    i.description = e.description;
    i.senderName = e.senderName;
    i.sampleDocumentIds = e.sampleDocumentIds.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref DocumentTemplate e, TemplateInput i, bool creating) {
    e.clientId = ClientId(optionalReference!ClientId(repos.clients, t, i.clientId, "Client"));
    e.schemaId = schemaOf(t, SchemaId(i.schemaId.strip)).id;
    e.documentTypeId = DocumentTypeId(optionalReference!DocumentTypeId(repos.documentTypes, t, i.documentTypeId, "Document type"));
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.senderName = i.senderName.strip;
    string[] samples;
    foreach (s; i.sampleDocumentIds) {
      auto id = optionalReference!DocumentId(repos.documents, t, s, "Sample document");
      if (id.length && !samples.canFind(id))
        samples ~= id;
    }
    e.sampleDocumentIds = samples;
  }

  protected override void beforeRemove(TenantId t, const DocumentTemplate e, UserId actor) {
    long open;
    foreach (d; repos.documents.findByReference(t, "templateId", e.id.value))
      if (!isFinal(d.status))
        open++;
    requireUnused("Template '" ~ e.name ~ "'", open, "documents in process");
  }

  DocumentTemplate activate(TenantId t, TemplateId id, UserId actor) {
    auto tpl = get(t, id);
    auto s = schemaOf(t, tpl.schemaId);
    if (!s.isActive)
      throw DaiException.ruleViolation("Template '" ~ tpl.name ~ "' needs an active schema ('" ~ s.name ~ "' is "
          ~ cast(string) s.status ~ ")");
    tpl.status = TemplateStatus.active;
    stampUpdated(tpl, actor, now);
    repos.templates.save(tpl);
    emit("template.activated", t, id.value);
    return tpl;
  }

  DocumentTemplate deactivate(TenantId t, TemplateId id, UserId actor) {
    auto tpl = get(t, id);
    if (!tpl.isActive)
      throw DaiException.ruleViolation("Template '" ~ tpl.name ~ "' is not active");
    tpl.status = TemplateStatus.inactive;
    stampUpdated(tpl, actor, now);
    repos.templates.save(tpl);
    emit("template.deactivated", t, id.value);
    return tpl;
  }
}

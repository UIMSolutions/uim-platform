/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The editable attributes of the maintained resources, as plain values.
/// One input type serves create (defaults below for missing members) and
/// update (PATCH: only the sent members change, see Changes!T). Members
/// ending in "_" (D keywords) have the API name without it.
module uim.platform.document_ai.application.dtos.inputs;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

struct ClientInput {
  string name;
  string description;
  int documentQuota;
  bool dataFeedbackEnabled = true;
}

struct DocumentTypeInput {
  string clientId;
  string name;
  string description;
  string category = "general";
  string defaultSchemaId;
  string[] supportedFileTypes;
}

struct SchemaInput {
  string clientId;
  string documentTypeId;
  string name;
  string description;
  string category = "general";
  string[] supportedLanguages;
}

struct SchemaFieldInput {
  string schemaId;
  string fieldScope = "header";
  int sequenceNumber = 10;
  string name;
  string label;
  string valueType = "string";
  bool required;
  string description;
  string defaultValue;
  string format;
}

struct TemplateInput {
  string clientId;
  string schemaId;
  string documentTypeId;
  string name;
  string description;
  string senderName;
  string[] sampleDocumentIds;
}

struct EnrichmentDataInput {
  string clientId;
  string documentTypeId;
  string subtype = "businessEntity";
  string externalId;
  string name;
  string description;
  string[] attributes;
}

struct TrainingJobInput {
  string clientId;
  string documentTypeId;
  string schemaId;
  string name;
  string description;
}

/// Upload of a document (metadata; the content stays with the caller).
struct DocumentInput {
  string clientId;
  string fileName;
  string mimeType;
  long fileSize;
  int pageCount = 1;
  string language = "en";
  string documentTypeId;
  string schemaId; /// "" = default schema of the document type
  string templateId;
  string extractionMethod; /// "" = templateBased with a template, else mlModel
  string[] labels;
}

/// Create a resource: an optional id ("" = generated) and the input.
struct CreateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput input;
}

/// Change a resource (PATCH semantics).
struct UpdateCommand(TInput) {
  TenantId tenantId;
  UserId actor;
  string id;
  Changes!TInput changes;
}

/// A create command with every member of the input set (tests, demo data).
CreateCommand!TInput createCommand(TInput)(TenantId t, UserId actor, string id, TInput input) {
  import std.traits : FieldNameTuple;

  CreateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.input.values = input;
  static foreach (name; FieldNameTuple!TInput)
    c.input.set(name);
  return c;
}

/// An update command changing the given members only.
UpdateCommand!TInput updateCommand(TInput)(TenantId t, UserId actor, string id, TInput values, string[] fields...) {
  UpdateCommand!TInput c;
  c.tenantId = t;
  c.actor = actor;
  c.id = id;
  c.changes.values = values;
  foreach (f; fields)
    c.changes.set(f);
  return c;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Entity → row (flat JSON object matching the EDM model). Derived facts
/// (names of referenced resources, counts, levels) are passed in by the
/// engine, which computes them once per request.
module uim.platform.document_ai.presentation.odata.serializers;

import std.traits : FieldNameTuple;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// ISO 8601 date-time (seconds, UTC) or null for 0.
Json isoTime(long stdTime) {
  auto text = isoTimeText(stdTime);
  return text.length > 0 ? Json(text) : Json(null);
}

Json texts(const string[] values) {
  auto a = Json.emptyArray;
  foreach (v; values)
    a ~= Json(v);
  return a;
}

/// Empty text → null (optional values and references).
Json textOrNull(string value) {
  return value.length > 0 ? Json(value) : Json(null);
}

/// 0.873 → 87
int percent(double share) pure {
  return cast(int)(clamp(share, 0.0, 1.0) * 100 + 0.5);
}

/// Round to 4 digits (stable JSON).
double rounded(double v) pure {
  import std.math : round;

  return round(v * 10_000) / 10_000;
}

private Json auditRow(E)(const E e) {
  auto j = Json.emptyObject;
  j["id"] = e.id.value;
  j["tenantId"] = e.tenantId.value;
  j["createdAt"] = isoTime(e.createdAt);
  j["createdBy"] = e.createdBy.value;
  j["updatedAt"] = isoTime(e.updatedAt);
  j["updatedBy"] = e.updatedBy.value;
  return j;
}

/// Names of referenced resources (computed by the engine).
struct DocumentNames {
  string client;
  string documentType;
  string schema;
  string template_;
  string enrichment;
}

Json documentRow(const AiDocument d, DocumentNames n, double threshold) {
  auto j = auditRow(d);
  j["clientId"] = textOrNull(d.clientId.value);
  j["clientName"] = n.client;
  j["fileName"] = d.fileName;
  j["fileType"] = cast(string) d.fileType;
  j["mimeType"] = d.mimeType;
  j["fileSize"] = d.fileSize;
  j["pageCount"] = d.pageCount;
  j["language"] = d.language;
  j["documentTypeId"] = textOrNull(d.documentTypeId.value);
  j["documentTypeName"] = n.documentType;
  j["schemaId"] = textOrNull(d.schemaId.value);
  j["schemaName"] = n.schema;
  j["templateId"] = textOrNull(d.templateId.value);
  j["templateName"] = n.template_;
  j["extractionMethod"] = cast(string) d.extractionMethod;
  j["status"] = cast(string) d.status;
  j["labels"] = texts(d.labels);
  j["labelsText"] = d.labels.join(", ");
  j["attempts"] = d.attempts;
  j["processedAt"] = isoTime(d.processedAt);
  j["confirmedAt"] = isoTime(d.confirmedAt);
  j["confirmedBy"] = d.confirmedBy;
  j["errorMessage"] = d.errorMessage;
  j["overallConfidence"] = rounded(d.overallConfidence);
  j["confidencePercent"] = percent(d.overallConfidence);
  j["confidenceLevel"] = d.extractedFieldCount > 0 ? cast(string) confidenceLevel(d.overallConfidence, threshold) : "";
  j["extractedFieldCount"] = d.extractedFieldCount;
  j["lineItemCount"] = d.lineItemCount;
  j["lowConfidenceCount"] = d.lowConfidenceCount;
  j["correctedFieldCount"] = d.correctedFieldCount;
  j["needsReview"] = d.needsReview;
  j["matchedEnrichmentId"] = textOrNull(d.matchedEnrichmentId.value);
  j["matchedEnrichmentName"] = n.enrichment;
  j["matchStatus"] = cast(string) d.matchStatus;
  j["matchScore"] = rounded(d.matchScore);
  return j;
}

Json extractedFieldRow(const ExtractedField f, string documentName, string documentStatus, double threshold) {
  auto j = auditRow(f);
  j["documentId"] = f.documentId.value;
  j["documentName"] = documentName;
  j["documentStatus"] = documentStatus;
  j["schemaFieldId"] = textOrNull(f.schemaFieldId.value);
  j["fieldScope"] = cast(string) f.fieldScope;
  j["rowIndex"] = f.rowIndex;
  j["sequenceNumber"] = f.sequenceNumber;
  j["name"] = f.name;
  j["label"] = f.label;
  j["valueType"] = cast(string) f.valueType;
  j["required"] = f.required;
  j["value"] = f.value;
  j["originalValue"] = f.originalValue;
  j["confidence"] = rounded(f.confidence);
  j["confidencePercent"] = percent(f.confidence);
  j["confidenceLevel"] = cast(string) confidenceLevel(f.confidence, threshold);
  j["page"] = f.page;
  j["coordinates"] = f.coordinates;
  j["corrected"] = f.corrected;
  j["correctedBy"] = f.correctedBy;
  j["missing"] = f.isMissing;
  return j;
}

/// Counts of a schema (computed by the engine).
struct SchemaFacts {
  long headerFields;
  long lineItemFields;
  long documents;
}

Json schemaRow(const Schema s, SchemaFacts f = SchemaFacts.init) {
  auto j = auditRow(s);
  j["clientId"] = textOrNull(s.clientId.value);
  j["documentTypeId"] = textOrNull(s.documentTypeId.value);
  j["name"] = s.name;
  j["description"] = s.description;
  j["category"] = cast(string) s.category;
  j["status"] = cast(string) s.status;
  j["supportedLanguages"] = texts(s.supportedLanguages);
  j["supportedLanguagesText"] = s.supportedLanguages.length ? s.supportedLanguages.join(", ") : "all";
  j["version"] = s.version_;
  j["basedOnId"] = textOrNull(s.basedOnId.value);
  j["activatedAt"] = isoTime(s.activatedAt);
  j["headerFieldCount"] = f.headerFields;
  j["lineItemFieldCount"] = f.lineItemFields;
  j["documentCount"] = f.documents;
  return j;
}

Json schemaFieldRow(const SchemaField f, string schemaStatus) {
  auto j = auditRow(f);
  j["schemaId"] = f.schemaId.value;
  j["schemaStatus"] = schemaStatus;
  j["fieldScope"] = cast(string) f.fieldScope;
  j["sequenceNumber"] = f.sequenceNumber;
  j["name"] = f.name;
  j["label"] = f.label;
  j["valueType"] = cast(string) f.valueType;
  j["required"] = f.required;
  j["description"] = f.description;
  j["defaultValue"] = f.defaultValue;
  j["format"] = f.format;
  return j;
}

Json templateRow(const DocumentTemplate t, string schemaName, long documents) {
  auto j = auditRow(t);
  j["clientId"] = textOrNull(t.clientId.value);
  j["schemaId"] = t.schemaId.value;
  j["schemaName"] = schemaName;
  j["documentTypeId"] = textOrNull(t.documentTypeId.value);
  j["name"] = t.name;
  j["description"] = t.description;
  j["senderName"] = t.senderName;
  j["status"] = cast(string) t.status;
  j["sampleDocumentIds"] = texts(t.sampleDocumentIds);
  j["sampleCount"] = t.sampleDocumentIds.length;
  j["documentCount"] = documents;
  return j;
}

Json documentTypeRow(const DocumentType t, string clientName, string schemaName, long documents) {
  auto j = auditRow(t);
  j["clientId"] = textOrNull(t.clientId.value);
  j["clientName"] = clientName;
  j["name"] = t.name;
  j["description"] = t.description;
  j["category"] = cast(string) t.category;
  j["defaultSchemaId"] = textOrNull(t.defaultSchemaId.value);
  j["defaultSchemaName"] = schemaName;
  j["supportedFileTypes"] = texts(t.supportedFileTypes);
  j["supportedFileTypesText"] = t.supportedFileTypes.length ? t.supportedFileTypes.join(", ") : "all";
  j["documentCount"] = documents;
  return j;
}

Json enrichmentRow(const EnrichmentData e, long matched) {
  auto j = auditRow(e);
  j["clientId"] = textOrNull(e.clientId.value);
  j["documentTypeId"] = textOrNull(e.documentTypeId.value);
  j["subtype"] = cast(string) e.subtype;
  j["externalId"] = e.externalId;
  j["name"] = e.name;
  j["description"] = e.description;
  j["attributes"] = texts(e.attributes);
  j["attributesText"] = e.attributes.join("; ");
  j["matchedDocumentCount"] = matched;
  return j;
}

Json clientRow(const Client c, long documents) {
  auto j = auditRow(c);
  j["name"] = c.name;
  j["description"] = c.description;
  j["documentQuota"] = c.documentQuota;
  j["dataFeedbackEnabled"] = c.dataFeedbackEnabled;
  j["documentCount"] = documents;
  j["quotaUsedPercent"] = c.documentQuota > 0 ? cast(int) min(documents * 100 / c.documentQuota, 999) : 0;
  return j;
}

Json trainingJobRow(const TrainingJob t, string schemaName, long now, long durationSeconds) {
  auto j = auditRow(t);
  j["clientId"] = textOrNull(t.clientId.value);
  j["documentTypeId"] = textOrNull(t.documentTypeId.value);
  j["schemaId"] = t.schemaId.value;
  j["schemaName"] = schemaName;
  j["name"] = t.name;
  j["description"] = t.description;
  j["status"] = cast(string) t.status;
  j["statusMessage"] = t.statusMessage;
  j["modelVersion"] = t.modelVersion;
  j["documentCount"] = t.documentCount;
  j["fieldCount"] = t.fieldCount;
  j["accuracy"] = rounded(t.accuracy);
  j["accuracyPercent"] = percent(t.accuracy);
  j["progressPercent"] = t.progressPercent(now, durationSeconds);
  j["startedAt"] = isoTime(t.startedAt);
  j["completedAt"] = isoTime(t.completedAt);
  return j;
}

Json userRow(const UserAccount u, long now) {
  auto j = auditRow(u);
  j["displayName"] = u.displayName;
  j["password"] = Json(null);
  j["scopes"] = texts(u.scopes);
  j["scopesText"] = u.scopes.join(", ");
  j["locked"] = u.locked;
  j["temporarilyLocked"] = !u.locked && u.isLockedAt(now);
  j["failedLogins"] = u.failedLogins;
  j["lastLoginAt"] = isoTime(u.lastLoginAt);
  return j;
}

Json statisticsRow(const DaiStatistics s) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!DaiStatistics) {
    static if (name == "tenantId")
      j[name] = s.tenantId.value;
    else
      j[name] = __traits(getMember, s, name);
  }
  return j;
}

Json processingRow(const ProcessingSummary s) {
  auto j = Json.emptyObject;
  j["documents"] = s.documents;
  j["extracted"] = s.extracted;
  j["failed"] = s.failed;
  j["messages"] = s.messages.join("\n");
  return j;
}

Json seedRow(const SeedResult r) @trusted {
  auto j = Json.emptyObject;
  static foreach (name; FieldNameTuple!SeedResult)
    j[name] = __traits(getMember, r, name);
  return j;
}

///
unittest {
  assert(percent(0.874) == 87 && percent(2) == 100 && rounded(0.123456) == 0.1235);
  Client c;
  c.id = ClientId("c");
  c.documentQuota = 4;
  assert(clientRow(c, 1)["quotaUsedPercent"].get!long == 25);
}

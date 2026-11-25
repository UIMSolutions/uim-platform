/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The EDM model of the service — the single description that drives the
/// OData v4 endpoint ($metadata incl. Fiori UI annotations), the REST API,
/// the CLI and the GtkD GUI.
///
/// Scopes: Read (reads), Process (documents and their values), Manage
/// (schemas, templates, master data, training), Admin (Users).
/// Timestamps are Edm.DateTimeOffset.
module uim.platform.document_ai.presentation.odata.model;

import uim.platform.service.presentation.odata;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string odataNamespace = "uim.documentai";

/// Audit properties (all computed).
private ODataEntitySetDef audited(ODataEntitySetDef set) {
  return set.property("tenantId", Edm.string_, "Tenant")
    .property("createdAt", Edm.dateTimeOffset, "Created At")
    .property("createdBy", Edm.string_, "Created By")
    .property("updatedAt", Edm.dateTimeOffset, "Changed At")
    .property("updatedBy", Edm.string_, "Changed By")
    .computed("tenantId", "createdAt", "createdBy", "updatedAt", "updatedBy");
}

ODataServiceModel documentAiModel() {
  auto m = new ODataServiceModel(odataNamespace, "DocumentAiService", "Document AI");

  // ── documents ───────────────────────────────────────────────────────────
  audited(m.entitySet("Documents", "Document")
      .property("id", Edm.string_, "Document", false)
      .property("clientId", Edm.string_, "Client")
      .property("clientName", Edm.string_, "Client Name")
      .property("fileName", Edm.string_, "File Name", false)
      .property("fileType", Edm.string_, "File Type")
      .property("mimeType", Edm.string_, "MIME Type")
      .property("fileSize", Edm.int64, "File Size (Bytes)")
      .property("pageCount", Edm.int32, "Pages")
      .property("language", Edm.string_, "Language")
      .property("documentTypeId", Edm.string_, "Document Type")
      .property("documentTypeName", Edm.string_, "Document Type Name")
      .property("schemaId", Edm.string_, "Schema")
      .property("schemaName", Edm.string_, "Schema Name")
      .property("templateId", Edm.string_, "Template")
      .property("templateName", Edm.string_, "Template Name")
      .property("extractionMethod", Edm.string_, "Extraction Method")
      .property("status", Edm.string_, "Status")
      .collection("labels", Edm.string_, "Labels")
      .property("labelsText", Edm.string_, "Labels")
      .property("attempts", Edm.int32, "Extraction Runs")
      .property("processedAt", Edm.dateTimeOffset, "Extracted At")
      .property("confirmedAt", Edm.dateTimeOffset, "Confirmed At")
      .property("confirmedBy", Edm.string_, "Confirmed By")
      .property("errorMessage", Edm.string_, "Message")
      .property("overallConfidence", Edm.double_, "Confidence")
      .property("confidencePercent", Edm.int32, "Confidence (%)")
      .property("confidenceLevel", Edm.string_, "Confidence Level")
      .property("extractedFieldCount", Edm.int32, "Values")
      .property("lineItemCount", Edm.int32, "Line Items")
      .property("lowConfidenceCount", Edm.int32, "To Review")
      .property("correctedFieldCount", Edm.int32, "Corrected")
      .property("needsReview", Edm.boolean, "Needs Review")
      .property("matchedEnrichmentId", Edm.string_, "Matched Record")
      .property("matchedEnrichmentName", Edm.string_, "Matched Record Name")
      .property("matchStatus", Edm.string_, "Match")
      .property("matchScore", Edm.double_, "Match Score")
      .computed("clientName", "fileType", "documentTypeName", "schemaName", "templateName", "status", "labelsText",
        "attempts", "processedAt", "confirmedAt", "confirmedBy", "errorMessage", "overallConfidence", "confidencePercent",
        "confidenceLevel", "extractedFieldCount", "lineItemCount", "lowConfidenceCount", "correctedFieldCount",
        "needsReview", "matchedEnrichmentId", "matchedEnrichmentName", "matchStatus", "matchScore")
      .immutableProps("clientId", "fileName", "mimeType", "fileSize"))
    .writable()
    .titled("Document", "Documents", "fileName", "documentTypeName")
    .columns("fileName", "documentTypeName", "status", "confidencePercent", "lowConfidenceCount", "createdAt")
    .filters("status", "documentTypeId", "schemaId", "clientId", "needsReview", "matchStatus")
    .scopes(readScope, processScope);

  audited(m.entitySet("ExtractedFields", "ExtractedField")
      .property("id", Edm.string_, "Value", false)
      .property("documentId", Edm.string_, "Document")
      .property("documentName", Edm.string_, "Document Name")
      .property("documentStatus", Edm.string_, "Document Status")
      .property("schemaFieldId", Edm.string_, "Schema Field")
      .property("fieldScope", Edm.string_, "Scope")
      .property("rowIndex", Edm.int32, "Row")
      .property("sequenceNumber", Edm.int32, "Sequence")
      .property("name", Edm.string_, "Field")
      .property("label", Edm.string_, "Label")
      .property("valueType", Edm.string_, "Type")
      .property("required", Edm.boolean, "Required")
      .property("value", Edm.string_, "Value")
      .property("originalValue", Edm.string_, "Extracted Value")
      .property("confidence", Edm.double_, "Confidence")
      .property("confidencePercent", Edm.int32, "Confidence (%)")
      .property("confidenceLevel", Edm.string_, "Confidence Level")
      .property("page", Edm.int32, "Page")
      .property("coordinates", Edm.string_, "Position")
      .property("corrected", Edm.boolean, "Corrected")
      .property("correctedBy", Edm.string_, "Corrected By")
      .property("missing", Edm.boolean, "Missing")
      .computed("documentId", "documentName", "documentStatus", "schemaFieldId", "fieldScope", "rowIndex", "sequenceNumber",
        "name", "label", "valueType", "required", "originalValue", "confidence", "confidencePercent", "confidenceLevel",
        "page", "coordinates", "corrected", "correctedBy", "missing"))
    .writable(false, true, false)
    .titled("Extracted Value", "Extracted Values", "label", "value")
    .columns("label", "value", "confidencePercent", "confidenceLevel", "corrected")
    .filters("documentId", "fieldScope", "confidenceLevel", "corrected", "missing")
    .scopes(readScope, processScope);

  // ── schemas and templates ───────────────────────────────────────────────
  audited(m.entitySet("Schemas", "Schema")
      .property("id", Edm.string_, "Schema", false)
      .property("clientId", Edm.string_, "Client")
      .property("documentTypeId", Edm.string_, "Document Type")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("category", Edm.string_, "Category")
      .property("status", Edm.string_, "Status")
      .collection("supportedLanguages", Edm.string_, "Languages")
      .property("supportedLanguagesText", Edm.string_, "Languages")
      .property("version", Edm.int32, "Version")
      .property("basedOnId", Edm.string_, "Based On")
      .property("activatedAt", Edm.dateTimeOffset, "Activated At")
      .property("headerFieldCount", Edm.int32, "Header Fields")
      .property("lineItemFieldCount", Edm.int32, "Line Item Fields")
      .property("documentCount", Edm.int32, "Documents")
      .computed("status", "supportedLanguagesText", "version", "basedOnId", "activatedAt", "headerFieldCount",
        "lineItemFieldCount", "documentCount"))
    .writable()
    .titled("Schema", "Schemas", "name", "description")
    .columns("name", "category", "version", "status", "headerFieldCount", "lineItemFieldCount")
    .filters("status", "category", "documentTypeId", "clientId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("SchemaFields", "SchemaField")
      .property("id", Edm.string_, "Field", false)
      .property("schemaId", Edm.string_, "Schema", false)
      .property("schemaStatus", Edm.string_, "Schema Status")
      .property("fieldScope", Edm.string_, "Scope")
      .property("sequenceNumber", Edm.int32, "Sequence")
      .property("name", Edm.string_, "Name", false)
      .property("label", Edm.string_, "Label")
      .property("valueType", Edm.string_, "Type")
      .property("required", Edm.boolean, "Required")
      .property("description", Edm.string_, "Description")
      .property("defaultValue", Edm.string_, "Default")
      .property("format", Edm.string_, "Format")
      .computed("schemaStatus")
      .immutableProps("schemaId"))
    .writable()
    .titled("Schema Field", "Schema Fields", "label", "name")
    .columns("fieldScope", "sequenceNumber", "name", "label", "valueType", "required")
    .filters("schemaId", "fieldScope", "valueType", "required")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Templates", "Template")
      .property("id", Edm.string_, "Template", false)
      .property("clientId", Edm.string_, "Client")
      .property("schemaId", Edm.string_, "Schema", false)
      .property("schemaName", Edm.string_, "Schema Name")
      .property("documentTypeId", Edm.string_, "Document Type")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("senderName", Edm.string_, "Sender")
      .property("status", Edm.string_, "Status")
      .collection("sampleDocumentIds", Edm.string_, "Sample Documents")
      .property("sampleCount", Edm.int32, "Samples")
      .property("documentCount", Edm.int32, "Documents")
      .computed("schemaName", "status", "sampleCount", "documentCount")
      .immutableProps("schemaId"))
    .writable()
    .titled("Template", "Templates", "name", "senderName")
    .columns("name", "senderName", "schemaName", "status", "documentCount")
    .filters("schemaId", "status", "documentTypeId", "clientId")
    .scopes(readScope, manageScope);

  // ── master data ─────────────────────────────────────────────────────────
  audited(m.entitySet("DocumentTypes", "DocumentType")
      .property("id", Edm.string_, "Document Type", false)
      .property("clientId", Edm.string_, "Client")
      .property("clientName", Edm.string_, "Client Name")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("category", Edm.string_, "Category")
      .property("defaultSchemaId", Edm.string_, "Default Schema")
      .property("defaultSchemaName", Edm.string_, "Default Schema Name")
      .collection("supportedFileTypes", Edm.string_, "File Types")
      .property("supportedFileTypesText", Edm.string_, "File Types")
      .property("documentCount", Edm.int32, "Documents")
      .computed("clientName", "defaultSchemaName", "supportedFileTypesText", "documentCount"))
    .writable()
    .titled("Document Type", "Document Types", "name", "category")
    .columns("name", "category", "defaultSchemaName", "supportedFileTypesText", "documentCount")
    .filters("category", "clientId", "defaultSchemaId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("EnrichmentData", "EnrichmentRecord")
      .property("id", Edm.string_, "Record", false)
      .property("clientId", Edm.string_, "Client")
      .property("documentTypeId", Edm.string_, "Document Type")
      .property("subtype", Edm.string_, "Subtype")
      .property("externalId", Edm.string_, "External ID")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .collection("attributes", Edm.string_, "Attributes")
      .property("attributesText", Edm.string_, "Attributes")
      .property("matchedDocumentCount", Edm.int32, "Matched Documents")
      .computed("attributesText", "matchedDocumentCount"))
    .writable()
    .titled("Enrichment Record", "Enrichment Data", "name", "externalId")
    .columns("name", "subtype", "externalId", "attributesText", "matchedDocumentCount")
    .filters("subtype", "clientId", "documentTypeId")
    .scopes(readScope, manageScope);

  audited(m.entitySet("Clients", "Client")
      .property("id", Edm.string_, "Client", false)
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("documentQuota", Edm.int32, "Document Quota")
      .property("dataFeedbackEnabled", Edm.boolean, "Data Feedback")
      .property("documentCount", Edm.int32, "Documents")
      .property("quotaUsedPercent", Edm.int32, "Quota Used (%)")
      .computed("documentCount", "quotaUsedPercent"))
    .writable()
    .titled("Client", "Clients", "name", "description")
    .columns("name", "documentQuota", "documentCount", "quotaUsedPercent", "dataFeedbackEnabled")
    .filters("dataFeedbackEnabled")
    .scopes(readScope, manageScope);

  // ── training ────────────────────────────────────────────────────────────
  audited(m.entitySet("TrainingJobs", "TrainingJob")
      .property("id", Edm.string_, "Training Job", false)
      .property("clientId", Edm.string_, "Client")
      .property("documentTypeId", Edm.string_, "Document Type")
      .property("schemaId", Edm.string_, "Schema", false)
      .property("schemaName", Edm.string_, "Schema Name")
      .property("name", Edm.string_, "Name", false)
      .property("description", Edm.string_, "Description")
      .property("status", Edm.string_, "Status")
      .property("statusMessage", Edm.string_, "Message")
      .property("modelVersion", Edm.string_, "Model Version")
      .property("documentCount", Edm.int32, "Documents")
      .property("fieldCount", Edm.int32, "Values")
      .property("accuracy", Edm.double_, "Accuracy")
      .property("accuracyPercent", Edm.int32, "Accuracy (%)")
      .property("progressPercent", Edm.int32, "Progress")
      .property("startedAt", Edm.dateTimeOffset, "Started At")
      .property("completedAt", Edm.dateTimeOffset, "Finished At")
      .computed("schemaName", "status", "statusMessage", "modelVersion", "documentCount", "fieldCount", "accuracy",
        "accuracyPercent", "progressPercent", "startedAt", "completedAt")
      .immutableProps("schemaId"))
    .writable()
    .titled("Training Job", "Training Jobs", "name", "schemaName")
    .columns("name", "schemaName", "status", "progressPercent", "accuracyPercent", "modelVersion")
    .filters("status", "schemaId", "clientId", "documentTypeId")
    .scopes(readScope, manageScope);

  // ── built-in login ──────────────────────────────────────────────────────
  audited(m.entitySet("Users", "User")
      .property("id", Edm.string_, "User", false)
      .property("displayName", Edm.string_, "Name")
      .property("password", Edm.string_, "Password")
      .collection("scopes", Edm.string_, "Scopes")
      .property("scopesText", Edm.string_, "Scopes")
      .property("locked", Edm.boolean, "Locked")
      .property("temporarilyLocked", Edm.boolean, "Temporarily Locked")
      .property("failedLogins", Edm.int32, "Failed Logins")
      .property("lastLoginAt", Edm.dateTimeOffset, "Last Login")
      .computed("scopesText", "temporarilyLocked", "failedLogins", "lastLoginAt"))
    .writable()
    .titled("User", "Users", "id", "displayName")
    .columns("id", "displayName", "scopesText", "locked", "lastLoginAt")
    .filters("locked")
    .scopes(adminScope, adminScope);

  // ── statistics ──────────────────────────────────────────────────────────
  auto stats = m.singletonSet("Statistics", "Statistic").keyed("tenantId")
    .property("tenantId", Edm.string_, "Tenant", false);
  foreach (name; statisticNames)
    stats.property(name, Edm.int32, statisticLabel(name));
  stats.titled("Statistics", "Statistics", "tenantId").scopes(readScope, manageScope);

  // ── result types ────────────────────────────────────────────────────────
  m.complexType("ProcessingResult")
    .property("documents", Edm.int32, "Documents")
    .property("extracted", Edm.int32, "Extracted")
    .property("failed", Edm.int32, "Failed")
    .property("messages", Edm.string_, "Messages");
  m.complexType("SeedResult")
    .property("clients", Edm.int32)
    .property("documentTypes", Edm.int32)
    .property("schemas", Edm.int32)
    .property("schemaFields", Edm.int32)
    .property("templates", Edm.int32)
    .property("enrichmentRecords", Edm.int32)
    .property("documents", Edm.int32)
    .property("trainingJobs", Edm.int32);

  // ── actions ─────────────────────────────────────────────────────────────
  m.action("ExtractDocument", "Document").parameter("id", Edm.string_, false).labelled("Extract").requires(processScope);
  m.action("ConfirmDocument", "Document").parameter("id", Edm.string_, false).labelled("Confirm").requires(processScope);
  m.action("RejectDocument", "Document").parameter("id", Edm.string_, false).parameter("reason", Edm.string_, false)
    .labelled("Reject").requires(processScope);
  m.action("ProcessPendingDocuments", "ProcessingResult").labelled("Process Pending Documents").requires(processScope);
  m.action("CorrectField", "ExtractedField").parameter("id", Edm.string_, false).parameter("value", Edm.string_)
    .labelled("Correct Value").requires(processScope);
  m.action("ActivateSchema", "Schema").parameter("id", Edm.string_, false).labelled("Activate").requires(manageScope);
  m.action("DeprecateSchema", "Schema").parameter("id", Edm.string_, false).labelled("Deprecate").requires(manageScope);
  m.action("CopySchema", "Schema").parameter("id", Edm.string_, false).parameter("newId", Edm.string_)
    .labelled("Copy as New Version").requires(manageScope);
  m.action("ActivateTemplate", "Template").parameter("id", Edm.string_, false).labelled("Activate").requires(manageScope);
  m.action("DeactivateTemplate", "Template").parameter("id", Edm.string_, false).labelled("Deactivate").requires(manageScope);
  m.action("StartTraining", "TrainingJob").parameter("id", Edm.string_, false).labelled("Start Training").requires(manageScope);
  m.action("CancelTraining", "TrainingJob").parameter("id", Edm.string_, false).labelled("Cancel").requires(manageScope);
  m.action("SeedDemoData", "SeedResult").labelled("Create Demo Content").requires(manageScope);
  return m;
}

/// Numeric members of the Statistics singleton (all of DaiStatistics but the tenant).
enum string[] statisticNames = [
    "documents", "pendingDocuments", "doneDocuments", "reviewDocuments", "confirmedDocuments", "rejectedDocuments",
    "failedDocuments", "documentsLast24h", "extractedFields", "correctedFields", "correctionRate", "averageConfidence",
    "matchedDocuments", "schemas", "activeSchemas", "templates", "documentTypes", "enrichmentRecords", "clients",
    "trainingJobs", "runningTrainingJobs", "bestAccuracy"
  ];

/// "pendingDocuments" → "Pending Documents"
string statisticLabel(string name) {
  import std.uni : isUpper, toUpper;

  string label;
  foreach (i, dchar c; name) {
    if (i == 0)
      label ~= toUpper(c);
    else {
      if (isUpper(c))
        label ~= ' ';
      label ~= c;
    }
  }
  return label.replace("Last24h", "(24 h)").replace("Last24 h", "(24 h)");
}

///
unittest {
  import std.traits : FieldNameTuple;

  auto m = documentAiModel();
  m.validate();
  assert(m.has("Documents") && m.find("Statistics").singleton && m.find("ExtractedFields").key == "id");
  assert(!m.find("ExtractedFields").insertable && m.find("ExtractedFields").updatable);
  assert(m.find("Documents").propertyOf("fileName").immutable_ && m.find("Documents").propertyOf("status").computed);
  assert(m.findAction("ProcessPendingDocuments").returnEdmType == "uim.documentai.ProcessingResult");
  assert(statisticLabel("pendingDocuments") == "Pending Documents");
  // the statistics model and the port agree
  string[] fields;
  static foreach (name; FieldNameTuple!DaiStatistics)
    static if (name != "tenantId")
      fields ~= name;
  assert(fields == statisticNames, fields.to!string);
}

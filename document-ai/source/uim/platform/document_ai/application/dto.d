/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.dto;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
// --- AiDocument ---

struct UploadDocumentRequest {
  TenantId tenantId;
  ClientId clientId;
  string fileName;
  string mimeType;
  long fileSize;
  string schemaId;
  string templateId;
  string documentTypeId;
  string language;
  string[][] labels;
}

struct ConfirmDocumentRequest {
  TenantId tenantId;
  ClientId clientId;
  DocumentId documentId;
  string[][] correctedFields;
}
// --- Schema ---

struct CreateSchemaRequest {
  TenantId tenantId;
  ClientId clientId;
  string documentTypeId;
  string name;
  string description;
  string[][] headerFields;
  string[][] lineItemFields;
  string[] supportedLanguages;
}

struct UpdateSchemaRequest {
  TenantId tenantId;
  ClientId clientId;
  SchemaId schemaId;
  string name;
  string description;
  string status;
  string[][] headerFields;
  string[][] lineItemFields;
}
// --- AiTemplate ---

struct CreateTemplateRequest {
  TenantId tenantId;
  ClientId clientId;
  SchemaId schemaId;
  string documentTypeId;
  string name;
  string description;
  string[][] regions;
}

struct UpdateTemplateRequest {
  TenantId tenantId;
  ClientId clientId;
  TemplateId templateId;
  string name;
  string description;
  string status;
  string[][] regions;
}
// --- AiDocument Type ---

struct CreateDocumentTypeRequest {
  TenantId tenantId;
  ClientId clientId;
  string name;
  string description;
  string category;
  SchemaId defaultSchemaId;
  string[] supportedFileTypes;
}

struct UpdateDocumentTypeRequest {
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  string category;
  SchemaId defaultSchemaId;
}
// --- Enrichment Data ---

struct CreateEnrichmentDataRequest {
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  string subtype;
  string[][] fields;
}

struct UpdateEnrichmentDataRequest {
  TenantId tenantId;
  ClientId clientId;
  EnrichmentDataId enrichmentDataId;
  string name;
  string description;
  string[][] fields;
}
// --- Training Job ---

struct CreateTrainingJobRequest {
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  SchemaId schemaId;
  string name;
  string description;
}

struct PatchTrainingJobRequest {
  TenantId tenantId;
  ClientId clientId;
  TrainingJobId trainingJobId;
  string targetStatus;
}
// --- Client ---

struct CreateClientRequest {
  TenantId tenantId;
  ClientId clientId;
  string name;
  string description;
  int documentQuota;
  string[][] labels;
}

struct PatchClientRequest {
  TenantId tenantId;
  ClientId clientId;
  string name;
  string description;
  int documentQuota;
  bool dataFeedbackEnabled;
  string[][] labels;
}
// --- Capabilities ---

struct CapabilitiesResponse {
  bool extraction;
  bool classification;
  bool enrichment;
  bool templateMatching;
  bool training;
  bool dataFeedback;
  bool multitenant;
  string[] supportedFileTypes;
  string[] supportedLanguages;
  string[] supportedDocumentTypes;
  string apiVersion;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.application.dto;

import uim.platform.document_ai.domain.types;

// --- Generic result ---

struct CommandResult {
  bool success;
  string id;
  string error;
}

// --- Document ---

struct UploadDocumentRequest {
  string tenantId;
  string clientId;
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
  string tenantId;
  string clientId;
  string documentId;
  string[][] correctedFields;
}

// --- Schema ---

struct CreateSchemaRequest {
  string tenantId;
  string clientId;
  string documentTypeId;
  string name;
  string description;
  string[][] headerFields;
  string[][] lineItemFields;
  string[] supportedLanguages;
}

struct UpdateSchemaRequest {
  string tenantId;
  string clientId;
  string schemaId;
  string name;
  string description;
  string status;
  string[][] headerFields;
  string[][] lineItemFields;
}

// --- Template ---

struct CreateTemplateRequest {
  string tenantId;
  string clientId;
  string schemaId;
  string documentTypeId;
  string name;
  string description;
  string[][] regions;
}

struct UpdateTemplateRequest {
  string tenantId;
  string clientId;
  string templateId;
  string name;
  string description;
  string status;
  string[][] regions;
}

// --- Document Type ---

struct CreateDocumentTypeRequest {
  string tenantId;
  string clientId;
  string name;
  string description;
  string category;
  string defaultSchemaId;
  string[] supportedFileTypes;
}

struct UpdateDocumentTypeRequest {
  string tenantId;
  string clientId;
  string documentTypeId;
  string name;
  string description;
  string category;
  string defaultSchemaId;
}

// --- Enrichment Data ---

struct CreateEnrichmentDataRequest {
  string tenantId;
  string clientId;
  string documentTypeId;
  string name;
  string description;
  string subtype;
  string[][] fields;
}

struct UpdateEnrichmentDataRequest {
  string tenantId;
  string clientId;
  string enrichmentDataId;
  string name;
  string description;
  string[][] fields;
}

// --- Training Job ---

struct CreateTrainingJobRequest {
  string tenantId;
  string clientId;
  string documentTypeId;
  string schemaId;
  string name;
  string description;
}

struct PatchTrainingJobRequest {
  string tenantId;
  string clientId;
  string trainingJobId;
  string targetStatus;
}

// --- Client ---

struct CreateClientRequest {
  string tenantId;
  string clientId;
  string name;
  string description;
  int documentQuota;
  string[][] labels;
}

struct PatchClientRequest {
  string tenantId;
  string clientId;
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

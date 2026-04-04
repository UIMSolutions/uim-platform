/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.document;

import uim.platform.document_ai.domain.types;

struct DocumentLabel {
  string key;
  string value;
}

struct Document {
  DocumentId id;
  TenantId tenantId;
  ClientId clientId;
  string fileName;
  FileType fileType;
  DocumentCategory category;
  DocumentTypeId documentTypeId;
  DocumentStatus status;
  string language;
  long fileSize;
  int pageCount;
  string mimeType;
  SchemaId schemaId;
  TemplateId templateId;
  ExtractionMethod extractionMethod;
  DocumentLabel[] labels;
  long uploadedAt;
  long processedAt;
  long createdAt;
  long modifiedAt;
}

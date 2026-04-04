/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.extraction_result;

import uim.platform.document_ai.domain.types;

struct ExtractedField {
  string name;
  string value;
  FieldValueType type;
  double confidence;
  int page;
  string coordinates;
}

struct LineItem {
  int rowIndex;
  ExtractedField[] fields;
}

struct ExtractionResult {
  ExtractionResultId id;
  TenantId tenantId;
  ClientId clientId;
  DocumentId documentId;
  SchemaId schemaId;
  ExtractionMethod method;
  ExtractedField[] headerFields;
  LineItem[] lineItems;
  double overallConfidence;
  int extractedFieldCount;
  int totalPages;
  long processedAt;
  long createdAt;
}

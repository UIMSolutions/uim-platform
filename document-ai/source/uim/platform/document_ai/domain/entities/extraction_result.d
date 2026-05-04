/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.extraction_result;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct ExtractedField {
  string name;
  string value;
  FieldValueType type;
  double confidence;
  int page;
  string coordinates;

  Json toJson() const {
    return Json.emptyObject
      .set("name", name)
      .set("value", value)
      .set("type", type.to!string)
      .set("confidence", confidence)
      .set("page", page)
      .set("coordinates", coordinates);
  }
}

struct LineItem {
  int rowIndex;
  ExtractedField[] fields;

  Json toJson() const {
    return Json.emptyObject
      .set("rowIndex", rowIndex)
      .set("fields", fields.map!(f => f.toJson()).array);
  }
}

struct ExtractionResult {
  mixin TenantEntity!ExtractionResultId;

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
  
  Json toJson() const {
    return entityToJson
      .set("clientId", clientId)
      .set("documentId", documentId)
      .set("schemaId", schemaId)
      .set("method", method.to!string)
      .set("headerFields", headerFields.map!(f => f.toJson()).array)
      .set("lineItems", lineItems.map!(li => li.toJson()).array)
      .set("overallConfidence", overallConfidence)
      .set("extractedFieldCount", extractedFieldCount)
      .set("totalPages", totalPages)
      .set("processedAt", processedAt);
  }
}

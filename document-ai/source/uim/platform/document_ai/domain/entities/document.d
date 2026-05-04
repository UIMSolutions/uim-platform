/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.document;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct DocumentLabel {
  string key;
  string value;
}

struct Document {
  mixin TenantEntity!DocumentId;

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
  
  Json toJson() const {
    return entityToJson
      .set("clientId", clientId)
      .set("fileName", fileName)
      .set("fileType", fileType.to!string)
      .set("category", category.to!string)
      .set("documentTypeId", documentTypeId)
      .set("status", status.to!string)
      .set("language", language)
      .set("fileSize", fileSize)
      .set("pageCount", pageCount)
      .set("mimeType", mimeType)
      .set("schemaId", schemaId)
      .set("templateId", templateId)
      .set("extractionMethod", extractionMethod.to!string)
      .set("labels", labels.map!(l => Json.emptyObject.set("key", l.key).set("value", l.value)).array)
      .set("uploadedAt", uploadedAt)
      .set("processedAt", processedAt);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.template_;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct TemplateRegion {
  string fieldName;
  int page;
  double x;
  double y;
  double width;
  double height;

  Json toJson() const {
      return Json.emptyObject
          .set("fieldName", fieldName)
          .set("page", page)
          .set("x", x)
          .set("y", y)
          .set("width", width)
          .set("height", height);
  }
}

struct Template {
 mixin TenantEntity!(TemplateId);

  ClientId clientId;
  SchemaId schemaId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  TemplateStatus status;
  TemplateRegion[] regions;
  string[] sampleDocumentIds;

  Json toJson() const {
      return entityToJson
          .set("clientId", clientId.value)
          .set("schemaId", schemaId.value)
          .set("documentTypeId", documentTypeId.value)
          .set("name", name)
          .set("description", description)
          .set("status", status.to!string)
          .set("regions", regions.map!(r => r.toJson()).array)
          .set("sampleDocumentIds", sampleDocumentIds.array);
  }
}

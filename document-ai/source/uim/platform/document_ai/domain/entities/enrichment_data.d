/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.entities.enrichment_data;

// import uim.platform.document_ai.domain.types;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
struct EnrichmentField {
  string key;
  string value;
}

struct EnrichmentData {
  mixin TenantEntity!(EnrichmentDataId);

  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  string subtype;
  EnrichmentField[] fields;

  Json toJson() const {
    auto j = entityToJson
      .set("clientId", clientId.value)
      .set("documentTypeId", documentTypeId.value)
      .set("name", name)
      .set("description", description)
      .set("subtype", subtype)
      .set("fields", fields.map!(f => Json.init
        .set("key", f.key)
        .set("value", f.value)).array);

    return j;
  }
}

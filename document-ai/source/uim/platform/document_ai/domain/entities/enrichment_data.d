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
  EnrichmentDataId id;
  TenantId tenantId;
  ClientId clientId;
  DocumentTypeId documentTypeId;
  string name;
  string description;
  string subtype;
  EnrichmentField[] fields;
  long createdAt;
  long modifiedAt;
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.extraction_results;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IExtractionResultRepository : ITenantRepository!(ExtractionResult, ExtractionResultId) {

  bool existsByDocument(TenantId tenantId, DocumentId docId, ClientId clientId);
  ExtractionResult findByDocument(TenantId tenantId, DocumentId docId, ClientId clientId);

  size_t countByClient(TenantId tenantId, ClientId clientId);  
  ExtractionResult[] findByClient(TenantId tenantId, ClientId clientId);
  
  ExtractionResult[] findBySchema(TenantId tenantId, SchemaId schemaId, ClientId clientId);

}

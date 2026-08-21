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

  size_t countByClient(TenantId tenantId, ClientId clientId);  
  ExtractionResult[] findByClient(TenantId tenantId, ClientId clientId);

  bool existsByDocument(TenantId tenantId, ClientId clientId, DocumentId docId);
  ExtractionResult findByDocument(TenantId tenantId, ClientId clientId, DocumentId docId);
  
  ExtractionResult[] findBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId);

}

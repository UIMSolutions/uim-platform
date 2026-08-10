/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.enrichment_datas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IEnrichmentDataRepository : ITenantRepository!(EnrichmentData, EnrichmentDataId) {

  size_t countByClient(TenantId tenantId, ClientId clientId);
  EnrichmentData[] findByClient(TenantId tenantId, ClientId clientId);
  EnrichmentData[] findByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId);
  EnrichmentData[] findBySubtype(TenantId tenantId, string subtype, ClientId clientId);
  
}

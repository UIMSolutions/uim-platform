/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.usecases.enrichment_data;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
interface IManageEnrichmentDataUseCase {  
  
  UsecaseResult createEnrichmentData(CreateEnrichmentDataRequest r);
  UsecaseResult updateEnrichmentData(UpdateEnrichmentDataRequest r);
  EnrichmentData getEnrichmentData(ClientId clientId, EnrichmentDataId id);
  EnrichmentData[] listEnrichmentData(ClientId clientId, DocumentTypeId typeId);
  EnrichmentData[] listEnrichmentData(ClientId clientId, string subtype);
  size_t countEnrichmentData(ClientId clientId);
  UsecaseResult deleteEnrichmentData(ClientId clientId, EnrichmentDataId id);

}

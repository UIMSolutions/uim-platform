/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.enrichment_datas;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.enrichment_data;

interface EnrichmentDataRepository {
  bool findById(EnrichmentDataId id, ClientId clientId);
  EnrichmentData findById(EnrichmentDataId id, ClientId clientId);

  EnrichmentData[] findByClient(ClientId clientId);
  EnrichmentData[] findByDocumentType(DocumentTypeId typeId, ClientId clientId);
  EnrichmentData[] findBySubtype(string subtype, ClientId clientId);
  
  void save(EnrichmentData ed);
  void update(EnrichmentData ed);
  void remove(EnrichmentDataId id, ClientId clientId);
  size_t countByClient(ClientId clientId);
}

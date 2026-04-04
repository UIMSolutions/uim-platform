/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.extraction_result_repository;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.extraction_result;

interface ExtractionResultRepository {
  ExtractionResult findById(ExtractionResultId id, ClientId clientId);
  ExtractionResult findByDocument(DocumentId docId, ClientId clientId);
  ExtractionResult[] findByClient(ClientId clientId);
  ExtractionResult[] findBySchema(SchemaId schemaId, ClientId clientId);
  void save(ExtractionResult r);
  void update(ExtractionResult r);
  void remove(ExtractionResultId id, ClientId clientId);
  long countByClient(ClientId clientId);
}

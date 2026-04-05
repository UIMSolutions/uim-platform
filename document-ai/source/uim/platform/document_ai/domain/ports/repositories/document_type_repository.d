/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.document_types;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document_type;

interface DocumentTypeRepository {
  DocumentType findById(DocumentTypeId id, ClientId clientId);
  DocumentType[] findByClient(ClientId clientId);
  DocumentType[] findByCategory(DocumentCategory category, ClientId clientId);
  void save(DocumentType dt);
  void update(DocumentType dt);
  void remove(DocumentTypeId id, ClientId clientId);
  long countByClient(ClientId clientId);
}

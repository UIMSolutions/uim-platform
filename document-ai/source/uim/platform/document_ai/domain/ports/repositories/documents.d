/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.documents;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document;

interface DocumentRepository {
  Document findById(DocumentId id, ClientId clientId);
  Document[] findByClient(ClientId clientId);
  Document[] findByStatus(DocumentStatus status, ClientId clientId);
  Document[] findByDocumentType(DocumentTypeId typeId, ClientId clientId);
  Document[] findByCategory(DocumentCategory category, ClientId clientId);
  void save(Document d);
  void update(Document d);
  void remove(DocumentId id, ClientId clientId);
  size_t countByClient(ClientId clientId);
  size_t countByStatus(DocumentStatus status, ClientId clientId);
}

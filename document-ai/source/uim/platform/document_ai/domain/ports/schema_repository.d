/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.domain.ports.repositories.schemas;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.schema;

interface SchemaRepository {
  Schema findById(SchemaId id, ClientId clientId);
  Schema[] findByClient(ClientId clientId);
  Schema[] findByDocumentType(DocumentTypeId typeId, ClientId clientId);
  Schema[] findByStatus(SchemaStatus status, ClientId clientId);
  void save(Schema s);
  void update(Schema s);
  void remove(SchemaId id, ClientId clientId);
  long countByClient(ClientId clientId);
}

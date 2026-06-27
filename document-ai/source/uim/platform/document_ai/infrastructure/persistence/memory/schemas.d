/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.schema;
// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.schema;
// import uim.platform.document_ai.domain.ports.repositories.schemas;


 
import uim.platform.document_ai;

// mixin(ShowModule!());

@safe:
class MemorySchemaRepository : TentRepository!(Schema, SchemaId), SchemaRepository {
  
  
  Schema[] findByClient(ClientId clientId) {
    foreach (s; findByTenant(tenantId))
      if (s.clientId == clientId)   
      return cl;
    return null;
  }

  Schema[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (cl).filter!(s => s.documentTypeId == typeId).array;
    return null;
  }

  Schema[] findByStatus(SchemaStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return (cl).filter!(s => s.status == status).array;
    return null;
  }

 
  size_t countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return (cl).length;
    return 0;
  }
}

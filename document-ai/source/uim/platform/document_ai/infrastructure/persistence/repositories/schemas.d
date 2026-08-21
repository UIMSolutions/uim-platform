/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.schemas;

// import uim.platform.document_ai.domain.entities.schema;
// import uim.platform.document_ai.domain.ports.repositories.schemas;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class SchemaRepository : TenantRepository!(Schema, SchemaId), ISchemaRepository {
  
  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  Schema[] filterByClient(Schema[] schemas, ClientId clientId) {
    return schemas.filter!(s => s.clientId == clientId).array;
  }

  Schema[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId);
  }

  size_t countByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId) {
    return findByDocumentType(tenantId, typeId, clientId).length;
  }

  Schema[] filterByDocumentType(Schema[] schemas, DocumentTypeId typeId) {
    return schemas.filter!(s => s.documentTypeId == typeId).array;
  }

  Schema[] findByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId) {
    return filterByDocumentType(findByClient(tenantId, clientId), typeId);
  }

  void removeByDocumentType(TenantId tenantId, DocumentTypeId typeId, ClientId clientId) {
    findByDocumentType(tenantId, typeId, clientId).each!(s => remove(s));
  }

  size_t countByStatus(TenantId tenantId, SchemaStatus status, ClientId clientId) {
    return findByStatus(tenantId, status, clientId).length;
  }

  Schema[] filterByStatus(Schema[] schemas, SchemaStatus status) {
    return schemas.filter!(s => s.status == status).array;
  }

  Schema[] findByStatus(TenantId tenantId, SchemaStatus status, ClientId clientId) {
    return filterByStatus(findByClient(tenantId, clientId), status);
  }

  void removeByStatus(TenantId tenantId, SchemaStatus status, ClientId clientId) {
    findByStatus(tenantId, status, clientId).each!(s => remove(s));
  }

}

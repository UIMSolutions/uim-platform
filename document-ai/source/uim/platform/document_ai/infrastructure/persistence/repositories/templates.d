/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.repositories.templates;

// import uim.platform.document_ai.domain.entities.template_;
// import uim.platform.document_ai.domain.ports.repositories.templates;
 
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class TemplateRepository : TenantRepository!(AiTemplate, TemplateId), ITemplateRepository {

  bool existsById(TenantId tenantId, ClientId clientId, TemplateId id) {
    return findByClient(tenantId, clientId).any!(t => t.id == id);
  }

  AiTemplate findById(TenantId tenantId, ClientId clientId, TemplateId id) {
    foreach (t; findByClient(tenantId, clientId)) {
      if (t.id == id)
        return t;
    }
    return AiTemplate.init;
  }

  size_t countByClient(TenantId tenantId, ClientId clientId) {
    return findByClient(tenantId, clientId).length;
  }

  AiTemplate[] filterByClient(AiTemplate[] templates, ClientId clientId) {
    return templates.filter!(t => t.clientId == clientId).array;
  }

  AiTemplate[] findByClient(TenantId tenantId, ClientId clientId) {
    return filterByClient(findByTenant(tenantId), clientId);
  }

  void removeByClient(TenantId tenantId, ClientId clientId) {
    findByClient(tenantId, clientId).each!(t => remove(t));
  }

  size_t countBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    return findBySchema(tenantId, clientId, schemaId).length;
  }

  AiTemplate[] filterBySchema(AiTemplate[] templates, SchemaId schemaId) {
    return templates.filter!(t => t.schemaId == schemaId).array;
  }

  AiTemplate[] findBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    return filterBySchema(findByClient(tenantId, clientId), schemaId);
  }

  void removeBySchema(TenantId tenantId, ClientId clientId, SchemaId schemaId) {
    findBySchema(tenantId, clientId, schemaId).each!(t => remove(t));
  }

  size_t countByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return findByDocumentType(tenantId, clientId, typeId).length;
  }

  AiTemplate[] filterByDocumentType(AiTemplate[] templates, DocumentTypeId typeId) {
    return templates.filter!(t => t.documentTypeId == typeId).array;
  }

  AiTemplate[] findByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    return filterByDocumentType(findByClient(tenantId, clientId), typeId);
  }

  void removeByDocumentType(TenantId tenantId, ClientId clientId, DocumentTypeId typeId) {
    findByDocumentType(tenantId, clientId, typeId).each!(t => remove(t));
  }

  size_t countByStatus(TenantId tenantId, ClientId clientId, TemplateStatus status) {
    return findByStatus(tenantId, clientId, status).length;
  }

  AiTemplate[] filterByStatus(AiTemplate[] templates, TemplateStatus status) {
    return templates.filter!(t => t.status == status).array;
  }

  AiTemplate[] findByStatus(TenantId tenantId, ClientId clientId, TemplateStatus status) {
    return filterByStatus(findByClient(tenantId, clientId), status);
  }

  void removeByStatus(TenantId tenantId, ClientId clientId, TemplateStatus status) {
    findByStatus(tenantId, clientId, status).each!(t => remove(t));
  }
}
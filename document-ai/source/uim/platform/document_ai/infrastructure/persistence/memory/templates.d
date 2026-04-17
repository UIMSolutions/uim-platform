/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.template;

// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.template_;
// import uim.platform.document_ai.domain.ports.repositories.templates;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class MemoryTemplateRepository : TemplateRepository {
  private Template[][string] store;

  bool existsById(ClientId clientId, TemplateId id) {
    return clientId in store ? store[clientId].any!(t => t.id == id) : false;
  }

  Template findById(ClientId clientId, TemplateId id) {
    if (clientId !in store)
      return Template.init;

    foreach (t; store[clientId]) {
      if (t.id == id)
        return t;
    }
    return Template.init;
  }

  Template[] findByClient(ClientId clientId) {
    if (clientId in store)
      return store[clientId];
    return [];
  }

  Template[] findBySchema(ClientId clientId, SchemaId schemaId) {
    if (clientId in store)
      return store[clientId].filter!(t => t.schemaId == schemaId).array;
    return [];
  }

  Template[] findByDocumentType(ClientId clientId, DocumentTypeId typeId) {
    if (clientId in store)
      return store[clientId].filter!(t => t.documentTypeId == typeId).array;
    return [];
  }

  Template[] findByStatus(ClientId clientId, TemplateStatus status) {
    if (clientId in store)
      return store[clientId].filter!(t => t.status == status).array;
    return [];
  }

  void save(Template t) {
    store[t.clientId] ~= t;
  }

  void update(Template t) {
    if (t.clientId in store) {
      foreach (existing; store[t.clientId]) {
        if (existing.id == t.id) {
          existing = t;
          return;
        }
      }
    }
  }

  void remove(ClientId clientId, TemplateId id) {
    if (clientId in store) {
      store[clientId] = store[clientId].filter!(t => t.id != id).array;
    }
  }

  size_t countByClient(ClientId clientId) {
    if (clientId in store)
      return store[clientId].length;
    return 0;
  }
}

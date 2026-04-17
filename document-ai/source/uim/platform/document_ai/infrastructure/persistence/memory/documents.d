/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.document;

// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.document;
// import uim.platform.document_ai.domain.ports.repositories.documents;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class MemoryDocumentRepository : DocumentRepository {
  private Document[][string] store;

  bool existsById(DocumentId id, ClientId clientId) {
    return clientId in store ? store[clientId].any!(d => d.id == id) : false;
  }

  Document findById(DocumentId id, ClientId clientId) {
    if (clientId !in store)
      return Document.init;

    foreach (d; store[clientId]) {
      if (d.id == id)
        return d;
    }
    return Document.init;
  }

  Document[] findByClient(ClientId clientId) {
    return clientId in store ? store[clientId] : [];
  }

  Document[] findByStatus(DocumentStatus status, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(d => d.status == status).array : null;
  }

  Document[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(d => d.documentTypeId == typeId).array : [];
  }

  Document[] findByCategory(DocumentCategory category, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(d => d.category == category).array : [];
  }

  void save(Document d) {
    if (d.clientId !in store) {
      Document[] docs;
      store[d.clientId] = docs;
    }
    store[d.clientId] ~= d;
  }

  void update(Document d) {
    if (d.clientId !in store)
      return;

    foreach (existing; store[d.clientId]) {
      if (existing.id == d.id) {
        existing = d;
        return;
      }
    }
  }

  void remove(DocumentId id, ClientId clientId) {
    if (clientId !in store)
      return;

    store[clientId] = store[clientId].filter!(d => d.id != id).array;
  }

  size_t countByClient(ClientId clientId) {
    return clientId in store ? store[clientId].length : 0;
  }

  size_t countByStatus(DocumentStatus status, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(d => d.status == status).array.length : 0;
  }
}

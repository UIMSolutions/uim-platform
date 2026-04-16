/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.document_types;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document_type;
import uim.platform.document_ai.domain.ports.repositories.document_types;

import std.algorithm : filter;
import std.array : array;

class MemoryDocumentTypeRepository : DocumentTypeRepository {
  private DocumentType[][string] store;

  bool existsById(DocumentTypeId id, ClientId clientId) {
    if (clientId !in store)
      return false;

    return store[clientId].any!(dt => dt.id == id);
  }

  DocumentType findById(DocumentTypeId id, ClientId clientId) {
    if (clientId !in store)
      return DocumentType.init;

    foreach (dt; store[clientId]) {
      if (dt.id == id)
        return dt;
    }
    return DocumentType.init;
  }

  DocumentType[] findByClient(ClientId clientId) {
    return clientId in store ? store[clientId] : null;
  }

  DocumentType[] findByCategory(DocumentCategory category, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(dt => dt.category == category).array : null;
  }

  void save(DocumentType dt) {
    if (dt.clientId !in store) {
      DocumentType[] types;
      store[dt.clientId] = types;
    }
    store[dt.clientId] ~= dt;
  }

  void update(DocumentType newType) {
    if (newType.clientId !in store)
      return;

    store[newType.clientId] = store[newType.clientId].map!(type => type.id == newType.id ? newType : type).array;
  }

  void remove(DocumentTypeId id, ClientId clientId) {
    if (clientId !in store)
      return;

    store[clientId] = store[clientId].filter!(type => type.id != id).array;
  }

  size_t countByClient(ClientId clientId) {
    return clientId in store ? store[clientId].length : 0;
  }
}

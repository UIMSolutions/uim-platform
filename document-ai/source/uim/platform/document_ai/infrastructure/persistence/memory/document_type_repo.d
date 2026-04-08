/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.document_type;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document_type;
import uim.platform.document_ai.domain.ports.repositories.document_types;

import std.algorithm : filter;
import std.array : array;

class MemoryDocumentTypeRepository : DocumentTypeRepository {
  private DocumentType[][string] store;

  DocumentType findById(DocumentTypeId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref dt; *cl) {
        if (dt.id == id)
          return dt;
      }
    }
    return DocumentType.init;
  }

  DocumentType[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  DocumentType[] findByCategory(DocumentCategory category, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(dt => dt.category == category).array;
    return [];
  }

  void save(DocumentType dt) {
    store[dt.clientId] ~= dt;
  }

  void update(DocumentType dt) {
    if (auto cl = dt.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == dt.id) {
          existing = dt;
          return;
        }
      }
    }
  }

  void remove(DocumentTypeId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).filter!(dt => dt.id != id).array;
    }
  }

  long countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }
}

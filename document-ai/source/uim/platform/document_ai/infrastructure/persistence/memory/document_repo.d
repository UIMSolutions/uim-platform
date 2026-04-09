/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.document;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.document;
import uim.platform.document_ai.domain.ports.repositories.documents;

import std.algorithm : filter, count, remove;
import std.array : array;

class MemoryDocumentRepository : DocumentRepository {
  private Document[][string] store;

  Document findById(DocumentId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref d; *cl) {
        if (d.id == id)
          return d;
      }
    }
    return Document.init;
  }

  Document[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  Document[] findByStatus(DocumentStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(d => d.status == status).array;
    return [];
  }

  Document[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(d => d.documentTypeId == typeId).array;
    return [];
  }

  Document[] findByCategory(DocumentCategory category, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(d => d.category == category).array;
    return [];
  }

  void save(Document d) {
    store[d.clientId] ~= d;
  }

  void update(Document d) {
    if (auto cl = d.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == d.id) {
          existing = d;
          return;
        }
      }
    }
  }

  void remove(DocumentId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).remove!(d => d.id == id);
    }
  }

  long countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }

  long countByStatus(DocumentStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).count!(d => d.status == status);
    return 0;
  }
}

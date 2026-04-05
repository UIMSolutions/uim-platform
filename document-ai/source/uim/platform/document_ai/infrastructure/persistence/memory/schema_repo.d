/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.schema_repo;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.schema;
import uim.platform.document_ai.domain.ports.repositories.schemas;

import std.algorithm : filter, remove;
import std.array : array;

class MemorySchemaRepository : SchemaRepository {
  private Schema[][string] store;

  Schema findById(SchemaId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref s; *cl) {
        if (s.id == id)
          return s;
      }
    }
    return Schema.init;
  }

  Schema[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  Schema[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(s => s.documentTypeId == typeId).array;
    return [];
  }

  Schema[] findByStatus(SchemaStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(s => s.status == status).array;
    return [];
  }

  void save(Schema s) {
    store[s.clientId] ~= s;
  }

  void update(Schema s) {
    if (auto cl = s.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == s.id) {
          existing = s;
          return;
        }
      }
    }
  }

  void remove(SchemaId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).remove!(s => s.id == id);
    }
  }

  long countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }
}

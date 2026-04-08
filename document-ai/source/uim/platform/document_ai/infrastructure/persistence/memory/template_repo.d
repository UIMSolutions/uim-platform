/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.template;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.template_;
import uim.platform.document_ai.domain.ports.repositories.templates;

import std.algorithm : filter;
import std.array : array;

class MemoryTemplateRepository : TemplateRepository {
  private Template[][string] store;

  Template findById(TemplateId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref t; *cl) {
        if (t.id == id)
          return t;
      }
    }
    return Template.init;
  }

  Template[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  Template[] findBySchema(SchemaId schemaId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(t => t.schemaId == schemaId).array;
    return [];
  }

  Template[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(t => t.documentTypeId == typeId).array;
    return [];
  }

  Template[] findByStatus(TemplateStatus status, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(t => t.status == status).array;
    return [];
  }

  void save(Template t) {
    store[t.clientId] ~= t;
  }

  void update(Template t) {
    if (auto cl = t.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == t.id) {
          existing = t;
          return;
        }
      }
    }
  }

  void remove(TemplateId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).filter!(t => t.id != id).array;
    }
  }

  long countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }
}

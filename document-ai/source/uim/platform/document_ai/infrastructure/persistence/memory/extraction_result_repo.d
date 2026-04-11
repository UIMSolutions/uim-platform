/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.extraction_result;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.extraction_result;
import uim.platform.document_ai.domain.ports.repositories.extraction_results;

import std.algorithm : filter;
import std.array : array;

class MemoryExtractionResultRepository : ExtractionResultRepository {
  private ExtractionResult[][string] store;

  ExtractionResult findById(ExtractionResultId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (r; *cl) {
        if (r.id == id)
          return r;
      }
    }
    return ExtractionResult.init;
  }

  ExtractionResult findByDocument(DocumentId docId, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (r; *cl) {
        if (r.documentId == docId)
          return r;
      }
    }
    return ExtractionResult.init;
  }

  ExtractionResult[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  ExtractionResult[] findBySchema(SchemaId schemaId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(r => r.schemaId == schemaId).array;
    return [];
  }

  void save(ExtractionResult r) {
    store[r.clientId] ~= r;
  }

  void update(ExtractionResult r) {
    if (auto cl = r.clientId in store) {
      foreach (existing; *cl) {
        if (existing.id == r.id) {
          existing = r;
          return;
        }
      }
    }
  }

  void remove(ExtractionResultId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).filter!(r => r.id != id).array;
    }
  }

  size_t countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).length;
    return 0;
  }
}

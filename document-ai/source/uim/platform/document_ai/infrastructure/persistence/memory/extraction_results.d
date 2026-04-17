/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.extraction_result;

// import uim.platform.document_ai.domain.types;
// import uim.platform.document_ai.domain.entities.extraction_result;
// import uim.platform.document_ai.domain.ports.repositories.extraction_results;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:
class MemoryExtractionResultRepository : ExtractionResultRepository {
  private ExtractionResult[][string] store;

  bool existsById(ClientId clientId, ExtractionResultId id) {
    return clientId in store ? store[clientId].any!(r => r.id == id) : false;
  }

  ExtractionResult findById(ClientId clientId, ExtractionResultId id) {
    if (clientId !in store)
      return ExtractionResult.init;

    foreach (r; store[clientId]) {
      if (r.id == id)
        return r;
    }
    return ExtractionResult.init;
  }

  ExtractionResult findByDocument(ClientId clientId, DocumentId docId) {
    if (clientId !in store)
      return ExtractionResult.init;

    foreach (r; store[clientId]) {
      if (r.documentId == docId)
        return r;
    }
    return ExtractionResult.init;
  }

  ExtractionResult[] findByClient(ClientId clientId) {
    return clientId in store ? store[clientId] : null;
  }

  ExtractionResult[] findBySchema(SchemaId schemaId, ClientId clientId) {
    return clientId in store ? store[clientId].filter!(r => r.schemaId == schemaId).array : null;
  }

  void save(ExtractionResult r) {
    store[r.clientId] ~= r;
  }

  void update(ExtractionResult r) {
    if (r.clientId !in store) {
      return;
    }
    foreach (existing; store[r.clientId]) {
      if (existing.id == r.id) {
        existing = r;
        return;
      }
    }
  }

  void remove(ExtractionResultId id, ClientId clientId) {
    if (clientId in store) {
      store[clientId] = store[clientId].filter!(r => r.id != id).array;
    }
  }

  size_t countByClient(ClientId clientId) {
    return clientId in store ? store[clientId].length : 0;
  }
}

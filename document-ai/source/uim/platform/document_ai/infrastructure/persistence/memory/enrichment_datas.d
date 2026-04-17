/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.enrichment_data;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.enrichment_data;
import uim.platform.document_ai.domain.ports.repositories.enrichment_datas;

import std.algorithm : filter;
import std.array : array;

class MemoryEnrichmentDataRepository : EnrichmentDataRepository {
  private EnrichmentData[][string] store;

  bool existsById(ClientId clientId, EnrichmentDataId id) {
    return clientId in store ? store[clientId].any!(ed => ed.id == id) : false;
  }

  EnrichmentData findById(ClientId clientId, EnrichmentDataId id) {
    foreach (enrichmentData; findByClient(clientId)) {
      if (enrichmentData.id == id)
        return enrichmentData;
    }
    return EnrichmentData.init;
  }

  EnrichmentData[] findByClient(ClientId clientId) {
    return clientId in store ? store[clientId] : null;
  }

  EnrichmentData[] findByDocumentType(ClientId clientId, DocumentTypeId typeId) {
    return findByClient(clientId).filter!(ed => ed.documentTypeId == typeId).array;
  }

  EnrichmentData[] findBySubtype(ClientId clientId, string subtype) {
    return findByClient(clientId).filter!(ed => ed.subtype == subtype).array;
  }

  void save(EnrichmentData ed) {
    store[ed.clientId] ~= ed;
  }

  void update(EnrichmentData ed) {
    foreach (existing; findByClient(clientId)) {
      if (existing.id == ed.id) {
        existing = ed;
        return;
      }
    }
  }

  void remove(EnrichmentDataId id, ClientId clientId) {
    if (clientId !in store)
      return;

    store[clientId] = [clientId].filter!(ed => ed.id != id).array;
  }

  size_t countByClient(ClientId clientId) {
    return findByClient(clientId).length;
  }
}

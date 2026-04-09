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

  EnrichmentData findById(EnrichmentDataId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      foreach (ref ed; *cl) {
        if (ed.id == id)
          return ed;
      }
    }
    return EnrichmentData.init;
  }

  EnrichmentData[] findByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return *cl;
    return [];
  }

  EnrichmentData[] findByDocumentType(DocumentTypeId typeId, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(ed => ed.documentTypeId == typeId).array;
    return [];
  }

  EnrichmentData[] findBySubtype(string subtype, ClientId clientId) {
    if (auto cl = clientId in store)
      return (*cl).filter!(ed => ed.subtype == subtype).array;
    return [];
  }

  void save(EnrichmentData ed) {
    store[ed.clientId] ~= ed;
  }

  void update(EnrichmentData ed) {
    if (auto cl = ed.clientId in store) {
      foreach (ref existing; *cl) {
        if (existing.id == ed.id) {
          existing = ed;
          return;
        }
      }
    }
  }

  void remove(EnrichmentDataId id, ClientId clientId) {
    if (auto cl = clientId in store) {
      *cl = (*cl).filter!(ed => ed.id != id).array;
    }
  }

  size_t countByClient(ClientId clientId) {
    if (auto cl = clientId in store)
      return cast(long)(*cl).length;
    return 0;
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.document_ai.infrastructure.persistence.memory.client;

import uim.platform.document_ai.domain.types;
import uim.platform.document_ai.domain.entities.client;
import uim.platform.document_ai.domain.ports.repositories.clients;

import std.algorithm : filter, count, remove;

class MemoryClientRepository : ClientRepository {
  private Client[] store;

  Client findById(ClientId id) {
    foreach (ref c; store) {
      if (c.id == id)
        return c;
    }
    return Client.init;
  }

  Client[] findByTenant(TenantId tenantId) {
    import std.array : array;
    return store.filter!(c => c.tenantId == tenantId).array;
  }

  void save(Client c) {
    store ~= c;
  }

  void update(Client c) {
    foreach (ref existing; store) {
      if (existing.id == c.id) {
        existing = c;
        return;
      }
    }
  }

  void remove(ClientId id) {
    store = store.remove!(c => c.id == id);
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.count!(c => c.tenantId == tenantId);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.infrastructure.persistence.memory.ingestion_tokens;

// import uim.platform.logging.domain.entities.ingestion_token;
// import uim.platform.logging.domain.ports.repositories.ingestion_tokens;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
class MemoryIngestionTokenRepository : IngestionTokenRepository {
  private IngestionToken[IngestionTokenId] store;

  bool existsById(IngestionTokenId id) {
    return (id in store) ? true : false;
  }

  IngestionToken findById(IngestionTokenId id) {
    return (existsById(id)) ? store[id] : IngestionToken.init;
  }

  IngestionToken[] findByTenant(TenantId tenantId) {
    return store.byValue.filter!(t => t.tenantId == tenantId).array;
  }

  IngestionToken findByHash(string tokenHash) {
    foreach (t; store)
      if (t.tokenHash == tokenHash)
        return t;
    return IngestionToken.init;
  }

  void save(IngestionToken t) {
    store[t.id] = t;
  }

  void update(IngestionToken t) {
    store[t.id] = t;
  }

  void remove(IngestionTokenId id) {
    store.remove(id);
  }
}

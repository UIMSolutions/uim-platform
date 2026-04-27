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
class MemoryIngestionTokenRepository : TenantRepository!(IngestionToken, IngestionTokenId), IngestionTokenRepository {

  bool existsByHash(string tokenHash) {
    return store.byValue.any!(t => t.tokenHash == tokenHash);
  }

  IngestionToken findByHash(string tokenHash) {
    foreach (t; findAll)
      if (t.tokenHash == tokenHash)
        return t;
    return IngestionToken.init;
  }

}

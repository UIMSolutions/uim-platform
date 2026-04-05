/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.domain.ports.repositories.ingestion_tokens;

// import uim.platform.logging.domain.entities.ingestion_token;
// import uim.platform.logging.domain.types;
import uim.platform.logging;

mixin(ShowModule!());

@safe:
interface IngestionTokenRepository {
  IngestionToken findById(IngestionTokenId id);
  IngestionToken[] findByTenant(TenantId tenantId);
  IngestionToken findByHash(string tokenHash);
  void save(IngestionToken t);
  void update(IngestionToken t);
  void remove(IngestionTokenId id);
}

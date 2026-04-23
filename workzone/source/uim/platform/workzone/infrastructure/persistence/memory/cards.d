/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.card;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.card;
import uim.platform.workzone.domain.ports.repositories.cards;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCardRepository : TenantRepository!(Card, CardId), CardRepository {

  size_t countByType(TenantId tenantId, CardType cardType) {
    return findByType(tenantId, cardType).length;
  }

  Card[] findByType(TenantId tenantId, CardType cardType) {
    return findByTenant(tenantId).filter!(c => c.cardType == cardType).array;
  }

  void removeByType(TenantId tenantId, CardType cardType) {
    return findByType(tenantId, cardType).each!(c => remove(c));
  }

}

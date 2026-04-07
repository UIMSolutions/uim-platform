/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.card_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.card;
import uim.platform.workzone.domain.ports.repositories.cards;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCardRepository : CardRepository {
  private Card[CardId] store;

  Card[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(c => c.tenantId == tenantId).array;
  }

  Card* findById(CardId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Card[] findByType(CardType cardType, TenantId tenantId) {
    return store.byValue().filter!(c => c.tenantId == tenantId && c.cardType == cardType).array;
  }

  void save(Card card) {
    store[card.id] = card;
  }

  void update(Card card) {
    store[card.id] = card;
  }

  void remove(CardId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

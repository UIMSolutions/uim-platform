/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.cards;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.card;

interface CardRepository
{
  Card[] findByTenant(TenantId tenantId);
  Card* findById(CardId id, TenantId tenantId);
  Card[] findByType(CardType cardType, TenantId tenantId);
  void save(Card card);
  void update(Card card);
  void remove(CardId id, TenantId tenantId);
}

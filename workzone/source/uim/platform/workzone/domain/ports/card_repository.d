module uim.platform.xyz.domain.ports.card_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.card;

interface CardRepository
{
    Card[] findByTenant(TenantId tenantId);
    Card* findById(CardId id, TenantId tenantId);
    Card[] findByType(CardType cardType, TenantId tenantId);
    void save(Card card);
    void update(Card card);
    void remove(CardId id, TenantId tenantId);
}

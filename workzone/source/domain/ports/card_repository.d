module domain.ports.card_repository;

import domain.types;
import domain.entities.card;

interface CardRepository
{
    Card[] findByTenant(TenantId tenantId);
    Card* findById(CardId id, TenantId tenantId);
    Card[] findByType(CardType cardType, TenantId tenantId);
    void save(Card card);
    void update(Card card);
    void remove(CardId id, TenantId tenantId);
}

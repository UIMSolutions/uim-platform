module infrastructure.persistence.memory.card_repo;

import domain.types;
import domain.entities.card;
import domain.ports.card_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryCardRepository : CardRepository
{
    private Card[CardId] store;

    Card[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(c => c.tenantId == tenantId).array;
    }

    Card* findById(CardId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    Card[] findByType(CardType cardType, TenantId tenantId)
    {
        return store.byValue().filter!(c => c.tenantId == tenantId && c.cardType == cardType).array;
    }

    void save(Card card) { store[card.id] = card; }
    void update(Card card) { store[card.id] = card; }
    void remove(CardId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}

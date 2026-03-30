module infrastructure.persistence.in_memory_legal_ground_repo;

import domain.types;
import domain.entities.legal_ground;
import domain.ports.legal_ground_repository;

class InMemoryLegalGroundRepository : LegalGroundRepository
{
    private LegalGround[] store;

    LegalGround[] findByTenant(TenantId tenantId)
    {
        LegalGround[] result;
        foreach (ref g; store)
            if (g.tenantId == tenantId)
                result ~= g;
        return result;
    }

    LegalGround* findById(LegalGroundId id, TenantId tenantId)
    {
        foreach (ref g; store)
            if (g.id == id && g.tenantId == tenantId)
                return &g;
        return null;
    }

    LegalGround[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        LegalGround[] result;
        foreach (ref g; store)
            if (g.tenantId == tenantId && g.dataSubjectId == dataSubjectId)
                result ~= g;
        return result;
    }

    LegalGround[] findByBasis(TenantId tenantId, LegalBasis basis)
    {
        LegalGround[] result;
        foreach (ref g; store)
            if (g.tenantId == tenantId && g.basis == basis)
                result ~= g;
        return result;
    }

    LegalGround[] findByPurpose(TenantId tenantId, ProcessingPurpose purpose)
    {
        LegalGround[] result;
        foreach (ref g; store)
            if (g.tenantId == tenantId && g.purpose == purpose)
                result ~= g;
        return result;
    }

    LegalGround[] findActive(TenantId tenantId, DataSubjectId dataSubjectId)
    {
        LegalGround[] result;
        foreach (ref g; store)
            if (g.tenantId == tenantId && g.dataSubjectId == dataSubjectId && g.isActive)
                result ~= g;
        return result;
    }

    void save(LegalGround ground)
    {
        store ~= ground;
    }

    void update(LegalGround ground)
    {
        foreach (ref g; store)
            if (g.id == ground.id && g.tenantId == ground.tenantId)
            {
                g = ground;
                return;
            }
    }

    void remove(LegalGroundId id, TenantId tenantId)
    {
        LegalGround[] kept;
        foreach (ref g; store)
            if (!(g.id == id && g.tenantId == tenantId))
                kept ~= g;
        store = kept;
    }
}

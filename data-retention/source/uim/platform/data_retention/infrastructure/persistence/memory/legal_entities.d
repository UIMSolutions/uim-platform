module uim.platform.data_retention.infrastructure.persistence.memory.legal_entities;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryLegalEntityRepository : TenantRepository!(LegalEntity, LegalEntityId), LegalEntityRepository {

        size_t countByActive(TenantId tenantId) {
            return findActive(tenantId).length;
        }

    LegalEntity[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(a => a.isActive).array;
    }

    void removeActive(TenantId tenantId) {
        findActive(tenantId).each!(entity => remove(entity.id));
    }

}

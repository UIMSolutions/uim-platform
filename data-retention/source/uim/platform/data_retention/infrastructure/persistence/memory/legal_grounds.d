module uim.platform.data_retention.infrastructure.persistence.memory.legal_grounds;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryLegalGroundRepository : TenantRepository!(LegalGround, LegalGroundId), LegalGroundRepository {

    LegalGround[] findAll(TenantId tenantId) {
        return findByTenant(tenantId);
    }

    size_t countByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByBusinessPurpose(tenantId, purposeId).length;
    }
    LegalGround[] filterByBusinessPurpose(LegalGround[] grounds, BusinessPurposeId purposeId) {
        return grounds.filter!(a => a.businessPurposeId == purposeId).array;
    }
    LegalGround[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return filterByBusinessPurpose(findByTenant(tenantId), purposeId);
    }
    void removeByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        findByBusinessPurpose(tenantId, purposeId).each!(a => remove(a));
    }

    size_t countByType(TenantId tenantId, LegalGroundType type) {
        return findByType(tenantId, type).length;
    }
    LegalGround[] filterByType(LegalGround[] grounds, LegalGroundType type) {
        return grounds.filter!(a => a.type == type).array;
    }
    LegalGround[] findByType(TenantId tenantId, LegalGroundType type) {
        return filterByType(findByTenant(tenantId), type);
    }
    void removeByType(TenantId tenantId, LegalGroundType type) {
        findByType(tenantId, type).each!(a => remove(a));
    }

}

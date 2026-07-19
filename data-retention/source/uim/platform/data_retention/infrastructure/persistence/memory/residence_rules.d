module uim.platform.data_retention.infrastructure.persistence.memory.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryResidenceRuleRepository : TenantRepository!(ResidenceRule, ResidenceRuleId), ResidenceRuleRepository {


    size_t countByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByBusinessPurpose(tenantId, purposeId).length;
    }
    ResidenceRule[] filterByBusinessPurpose(ResidenceRule[] rules, BusinessPurposeId purposeId) {
        return rules.filter!(a => a.businessPurposeId == purposeId).array;
    }
        ResidenceRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    void removeByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        findByBusinessPurpose(tenantId, purposeId).each!(entity => remove(entity));
    }
    
    size_t countByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByLegalGround(tenantId, groundId).length;
    }
    ResidenceRule[] filterByLegalGround(ResidenceRule[] rules, LegalGroundId groundId) {
        return rules.filter!(a => a.legalGroundId == groundId).array;
    }
    ResidenceRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByTenant(tenantId).filter!(a => a.legalGroundId == groundId).array;
    }
    void removeByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        findByLegalGround(tenantId, groundId).each!(entity => remove(entity));
    }

}

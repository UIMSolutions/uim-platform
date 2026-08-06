module uim.platform.data_retention.infrastructure.persistence.repositories.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class RetentionRuleRepository : TenantRepository!(RetentionRule, RetentionRuleId), IRetentionRuleRepository {

    size_t countByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByBusinessPurpose(tenantId, purposeId).length;
    }

    RetentionRule[] filterByBusinessPurpose(RetentionRule[] rules, BusinessPurposeId purposeId) {
        return rules.filter!(a => a.businessPurposeId == purposeId).array;
    }

    RetentionRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        return findByTenant(tenantId).filter!(a => a.businessPurposeId == purposeId).array;
    }
    void removeByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId) {
        findByBusinessPurpose(tenantId, purposeId).each!(entity => remove(entity));
    }

    size_t countByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByLegalGround(tenantId, groundId).length;
    }

    RetentionRule[] filterByLegalGround(RetentionRule[] rules, LegalGroundId groundId) {
        return rules.filter!(a => a.legalGroundId == groundId).array;
    }
    
    RetentionRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return filterByLegalGround(findByTenant(tenantId), groundId);
    }
    void removeByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        findByLegalGround(tenantId, groundId).each!(entity => remove(entity));
    }

}

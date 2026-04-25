module uim.platform.data_retention.infrastructure.persistence.memory.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class MemoryRetentionRuleRepository : TenantRepository!(RetentionRule, RetentionRuleId), RetentionRuleRepository {

    size_t countByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByLegalGround(tenantId, groundId).length;
    }

    RetentionRule[] filterByLegalGround(RetentionRule[] rules, LegalGroundId groundId) {
        return rules.filter!(a => a.legalGroundId == groundId).array;
    }
    
    RetentionRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        return findByTenant(tenantId).filterByLegalGround(groundId);
    }
    void removeByLegalGround(TenantId tenantId, LegalGroundId groundId) {
        findByLegalGround(tenantId, groundId).removeAll;
    }

}

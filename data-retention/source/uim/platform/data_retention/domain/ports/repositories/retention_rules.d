module uim.platform.data_retention.domain.ports.repositories.retention_rules;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

interface RetentionRuleRepository : ITentRepository!(RetentionRule, RetentionRuleId) {

    RetentionRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    RetentionRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId);

}

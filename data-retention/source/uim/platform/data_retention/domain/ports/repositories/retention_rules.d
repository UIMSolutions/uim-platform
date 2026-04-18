module uim.platform.data_retention.domain.ports.repositories.retention_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface RetentionRuleRepository { //: ITenantRepository!(RetentionRule, RetentionRuleId) {
    bool existsById(RetentionRuleId id);
    RetentionRule findById(RetentionRuleId id);

    RetentionRule[] findAll(TenantId tenantId);
    RetentionRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    RetentionRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId);

    void save(RetentionRule a);
    void save(TenantId tenantId, RetentionRule a);
    void update(RetentionRule a);
    void update(TenantId tenantId, RetentionRule a);
}

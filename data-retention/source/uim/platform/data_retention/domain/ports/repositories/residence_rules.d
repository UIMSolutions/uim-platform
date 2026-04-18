module uim.platform.data_retention.domain.ports.repositories.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ResidenceRuleRepository { //: ITenantRepository!(ResidenceRule, ResidenceRuleId) {
    bool existsById(ResidenceRuleId id);
    ResidenceRule findById(ResidenceRuleId id);

    ResidenceRule[] findAll(TenantId tenantId);
    ResidenceRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    ResidenceRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId);

    void save(ResidenceRule a);
    void save(TenantId tenantId, ResidenceRule a);
    void update(ResidenceRule a);
    void update(TenantId tenantId, ResidenceRule a);
}

module uim.platform.data_retention.domain.ports.repositories.residence_rules;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface ResidenceRuleRepository : ITenantRepository!(ResidenceRule, ResidenceRuleId) {

    ResidenceRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    ResidenceRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId);


}

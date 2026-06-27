module uim.platform.data_retention.domain.ports.repositories.residence_rules;
import uim.platform.data_retention;

// mixin(ShowModule!());

@safe:

interface ResidenceRuleRepository : ITentRepository!(ResidenceRule, ResidenceRuleId) {

    ResidenceRule[] findByBusinessPurpose(TenantId tenantId, BusinessPurposeId purposeId);
    ResidenceRule[] findByLegalGround(TenantId tenantId, LegalGroundId groundId);


}

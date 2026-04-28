module uim.platform.data_retention.domain.entities.residence_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ResidenceRule {
    ResidenceRuleId id;
    TenantId tenantId;
    BusinessPurposeId businessPurposeId;
    LegalGroundId legalGroundId;
    int duration;
    PeriodUnit periodUnit = PeriodUnit.years;
    bool isActive = true;
    UserId createdBy;
    long createdAt;
    long updatedAt;
}

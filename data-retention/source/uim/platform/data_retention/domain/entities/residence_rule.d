module uim.platform.data_retention.domain.entities.residence_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct ResidenceRule {
    mixin TenantEntity!(ResidenceRuleId);

    BusinessPurposeId businessPurposeId;
    LegalGroundId legalGroundId;
    int duration;
    PeriodUnit periodUnit = PeriodUnit.years;
    bool isActive = true;

    Json toJson() const {
        return entityToJson
            .set("businessPurposeId", businessPurposeId)
            .set("legalGroundId", legalGroundId)
            .set("duration", duration)
            .set("periodUnit", periodUnit)
            .set("isActive", isActive);
    }
}

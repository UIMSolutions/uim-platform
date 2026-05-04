module uim.platform.data_retention.domain.entities.retention_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct RetentionRule {
    mixin TenantEntity!(RetentionRuleId);

    BusinessPurposeId businessPurposeId;
    LegalGroundId legalGroundId;
    int duration;
    PeriodUnit periodUnit = PeriodUnit.years;
    DeletionActionType actionOnExpiry = DeletionActionType.delete_;
    bool isActive = true;

    Json toJson() const {
        return entityToJson
            .set("businessPurposeId", businessPurposeId)
            .set("legalGroundId", legalGroundId)
            .set("duration", duration)
            .set("periodUnit", periodUnit)
            .set("actionOnExpiry", actionOnExpiry)
            .set("isActive", isActive);
    }

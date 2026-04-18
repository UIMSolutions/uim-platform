module uim.platform.data_retention.domain.entities.retention_rule;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct RetentionRule {
    RetentionRuleId id;
    TenantId tenantId;
    BusinessPurposeId businessPurposeId;
    LegalGroundId legalGroundId;
    int duration;
    PeriodUnit periodUnit = PeriodUnit.years;
    DeletionActionType actionOnExpiry = DeletionActionType.delete_;
    bool isActive = true;
    string createdBy;
    long createdAt;
    long updatedAt;
}

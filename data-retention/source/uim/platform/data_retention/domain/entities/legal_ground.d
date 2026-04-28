module uim.platform.data_retention.domain.entities.legal_ground;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct LegalGround {
    LegalGroundId id;
    TenantId tenantId;
    BusinessPurposeId businessPurposeId;
    string name;
    string description;
    LegalGroundType type = LegalGroundType.consent;
    long referenceDate;
    long residenceEndDate;
    long retentionEndDate;
    bool isActive = true;
    UserId createdBy;
    long createdAt;
    long updatedAt;
}

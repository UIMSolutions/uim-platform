module uim.platform.data_retention.domain.entities.business_purpose;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct BusinessPurpose {
    BusinessPurposeId id;
    TenantId tenantId;
    string name;
    string description;
    ApplicationGroupId applicationGroupId;
    DataSubjectRoleId dataSubjectRoleId;
    LegalEntityId legalEntityId;
    BusinessPurposeStatus status = BusinessPurposeStatus.inactive;
    long referenceDate;
    long endOfPurposeDate;
    string createdBy;
    long createdAt;
    long updatedAt;
}

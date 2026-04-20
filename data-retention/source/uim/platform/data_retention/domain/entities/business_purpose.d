module uim.platform.data_retention.domain.entities.business_purpose;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct BusinessPurpose {
    mixin TenantEntity!(BusinessPurposeId);

    string name;
    string description;
    ApplicationGroupId applicationGroupId;
    DataSubjectRoleId dataSubjectRoleId;
    LegalEntityId legalEntityId;
    BusinessPurposeStatus status = BusinessPurposeStatus.inactive;
    long referenceDate;
    long endOfPurposeDate;
    string createdBy;
    
    Json toJson() const {
        auto j = entityToJson
            .set("name", name)
            .set("description", description)
            .set("applicationGroupId", applicationGroupId.value)
            .set("dataSubjectRoleId", dataSubjectRoleId.value)
            .set("legalEntityId", legalEntityId.value)
            .set("status", status.toString())
            .set("referenceDate", referenceDate)
            .set("endOfPurposeDate", endOfPurposeDate);

        return j;
    }
}

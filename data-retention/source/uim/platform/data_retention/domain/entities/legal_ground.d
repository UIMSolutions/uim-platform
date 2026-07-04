module uim.platform.data_retention.domain.entities.legal_ground;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct LegalGround {
    mixin TenantEntity!(LegalGroundId);

    BusinessPurposeId businessPurposeId;
    string name;
    string description;
    LegalGroundType type = LegalGroundType.consent;
    long referenceDate;
    long residenceEndDate;
    long retentionEndDate;
    bool isActive = true;

    Json toJson() const {
        return entityToJson
            .set("businessPurposeId", businessPurposeId)
            .set("name", name)
            .set("description", description)
            .set("type", type)
            .set("referenceDate", referenceDate)
            .set("residenceEndDate", residenceEndDate)
            .set("retentionEndDate", retentionEndDate)
            .set("isActive", isActive);
    }
}

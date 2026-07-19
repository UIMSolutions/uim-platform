module uim.platform.data_retention.domain.entities.data_subject;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DataSubject {
    mixin TenantEntity!(DataSubjectId);

    DataSubjectRoleId roleId;
    ApplicationGroupId applicationGroupId;
    string externalId;
    DataLifecycleStatus lifecycleStatus = DataLifecycleStatus.active;
    long endOfPurposeDate;
    long endOfRetentionDate;
    long blockedAt;
    long deletedAt;

    Json toJson() const {
        return entityToJson
            .set("roleId", roleId)
            .set("applicationGroupId", applicationGroupId)
            .set("externalId", externalId)
            .set("lifecycleStatus", lifecycleStatus)
            .set("endOfPurposeDate", endOfPurposeDate)
            .set("endOfRetentionDate", endOfRetentionDate)
            .set("blockedAt", blockedAt)
            .set("deletedAt", deletedAt);
    }
}

module uim.platform.data_retention.domain.entities.data_subject;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DataSubject {
    DataSubjectId id;
    TenantId tenantId;
    DataSubjectRoleId roleId;
    ApplicationGroupId applicationGroupId;
    string externalId;
    DataLifecycleStatus lifecycleStatus = DataLifecycleStatus.active;
    long endOfPurposeDate;
    long endOfRetentionDate;
    long blockedAt;
    long deletedAt;
    string createdBy;
    long createdAt;
    long updatedAt;
}

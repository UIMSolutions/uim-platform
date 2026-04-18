module uim.platform.data_retention.domain.entities.data_subject_role;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DataSubjectRole {
    DataSubjectRoleId id;
    TenantId tenantId;
    string name;
    string description;
    bool isActive = true;
    string createdBy;
    long createdAt;
    long updatedAt;
}

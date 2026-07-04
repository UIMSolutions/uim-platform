module uim.platform.data_retention.domain.entities.data_subject_role;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct DataSubjectRole {
    mixin TenantEntity!(DataSubjectRoleId);

    string name;
    string description;
    bool isActive = true;
    
    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("isActive", isActive);
    }
}

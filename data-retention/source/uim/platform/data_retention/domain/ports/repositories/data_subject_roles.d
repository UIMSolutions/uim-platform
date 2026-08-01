module uim.platform.data_retention.domain.ports.repositories.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IDataSubjectRoleRepository : ITenantRepository!(DataSubjectRole, DataSubjectRoleId) {

    DataSubjectRole[] findActive(TenantId tenantId);

}

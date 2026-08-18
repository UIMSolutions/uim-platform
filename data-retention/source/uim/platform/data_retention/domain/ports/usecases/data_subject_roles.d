/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageDataSubjectRolesUseCase { 

    UsecaseResult createDataSubjectRole(CreateDataSubjectRoleRequest req);
    UsecaseResult updateDataSubjectRole(TenantId tenantId, DataSubjectRoleId id, UpdateDataSubjectRoleRequest req);
    bool hasDataSubjectRole(TenantId tenantId, DataSubjectRoleId id);
    DataSubjectRole getDataSubjectRole(TenantId tenantId, DataSubjectRoleId id);
    DataSubjectRole[] listDataSubjectRoles(TenantId tenantId);
    UsecaseResult deleteDataSubjectRole(TenantId tenantId, DataSubjectRoleId id);

}


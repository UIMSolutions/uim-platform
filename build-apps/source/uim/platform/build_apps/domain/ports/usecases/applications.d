/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.ports.usecases.manage.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

interface IManageApplicationsUseCase { 
    
    Application getApplication(TenantId tenantId, ApplicationId id);
    Application[] listApplications(TenantId tenantId);
    Application[] listApplications(TenantId tenantId, string owner);
    CommandResult createApplication(ApplicationDTO dto);
    CommandResult updateApplication(ApplicationDTO dto);
    CommandResult deleteApplication(TenantId tenantId, ApplicationId id);
    
}

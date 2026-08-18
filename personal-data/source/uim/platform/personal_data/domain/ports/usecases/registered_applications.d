/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.registered_applications;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageRegisteredApplicationsUseCase { 

    UsecaseResult createApplication(CreateRegisteredApplicationRequest r);
    RegisteredApplication getApplication(TenantId tenantId, RegisteredApplicationId id);
    RegisteredApplication[] listApplications(TenantId tenantId);
    UsecaseResult updateApplication(UpdateRegisteredApplicationRequest r);
    UsecaseResult activateApplication(TenantId tenantId, RegisteredApplicationId id);
    UsecaseResult suspendApplication(TenantId tenantId, RegisteredApplicationId id);
    UsecaseResult deleteApplication(TenantId tenantId, RegisteredApplicationId id);

}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.event_applications;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageEventApplicationsUseCase { 

    EventApplication getApplication(TenantId tenantId, EventApplicationId id);
    EventApplication[] listApplications(TenantId tenantId);
    EventApplication[] listApplications(TenantId tenantId, BrokerServiceId serviceId);
    CommandResult createApplication(EventApplicationDTO dto);
    CommandResult updateApplication(EventApplicationDTO dto);
    CommandResult deleteApplication(TenantId tenantId, EventApplicationId id);

}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageBrokerServicesUseCase { 

    BrokerService getService(TenantId tenantId, BrokerServiceId id);
    BrokerService[] listServices(TenantId tenantId);
    BrokerService[] listServices(TenantId tenantId, BrokerServiceStatus status);
    UsecaseResult createService(BrokerServiceDTO dto);
    UsecaseResult updateService(BrokerServiceDTO dto);
    UsecaseResult deleteService(TenantId tenantId, BrokerServiceId id);
}


/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.service_instances;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IManageServiceInstancesUseCase {

    UsecaseResult createServiceInstance(CreateServiceInstanceRequest r);

    UsecaseResult updateServiceInstance(UpdateServiceInstanceRequest r);

    ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id);

    ServiceInstance[] listServiceInstances(TenantId tenantId);

    UsecaseResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id);

    size_t countServiceInstances(TenantId tenantId);

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.service_instances;

// /* import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_instance;
// import uim.platform.kyma.domain.ports.repositories.service_instances;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for BTP service instance management in Kyma.
interface IManageServiceInstancesUseCase {

  UsecaseResult createServiceInstance(CreateServiceInstanceRequest req);

  UsecaseResult updateServiceInstance(UpdateServiceInstanceRequest req);

  bool hasServiceInstance(TenantId tenantId, ServiceInstanceId id);

  ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id);

  ServiceInstance[] listServiceInstances(TenantId tenantId, NamespaceId nsId);

  ServiceInstance[] listServiceInstances(TenantId tenantId, KymaEnvironmentId envId);

  UsecaseResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id);
  
}



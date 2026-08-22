/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.service_bindings;

// /* import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.service_binding;
// import uim.platform.kyma.domain.ports.repositories.service_bindings;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for service binding management.
interface IManageServiceBindingsUseCase {

  UsecaseResult createServiceBinding(CreateServiceBindingRequest req);

  UsecaseResult updateServiceBinding(UpdateServiceBindingRequest req);

  bool hasServiceBinding(TenantId tenantId, ServiceBindingId id);

  ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id);

  ServiceBinding[] listServiceBindingsByNamespace(TenantId tenantId, NamespaceId nsId);

  ServiceBinding[] listServiceBindingsByServiceInstance(TenantId tenantId, ServiceInstanceId instId);

  UsecaseResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id);
  
}

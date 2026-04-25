/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.service_binding;

// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.service_binding;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying service bindings.
interface IServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {

  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  ServiceBinding[] filterByServiceInstance(ServiceBinding[] bindings, ServiceInstanceId instanceId);
  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);

  size_t countByApp(TenantId tenantId, AppId appId);
  ServiceBinding[] filterByApp(ServiceBinding[] bindings, AppId appId);
  ServiceBinding[] findByApp(TenantId tenantId, AppId appId);
  void removeByApp(TenantId tenantId, AppId appId);

}

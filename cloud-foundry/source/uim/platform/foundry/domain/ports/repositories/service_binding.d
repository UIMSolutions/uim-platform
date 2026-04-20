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
  size_t countByServiceInstance(ServiceInstanceId instancetenantId, id tenantId);
  ServiceBinding[] findByServiceInstance(ServiceInstanceId instancetenantId, id tenantId);
  void removeByServiceInstance(ServiceInstanceId instancetenantId, id tenantId);

  size_t countByApp(AppId apptenantId, id tenantId);
  ServiceBinding[] findByApp(AppId apptenantId, id tenantId);
  void removeByApp(AppId apptenantId, id tenantId);
}

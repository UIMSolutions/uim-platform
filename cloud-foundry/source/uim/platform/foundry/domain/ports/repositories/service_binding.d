/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.domain.ports.repositories.service_binding;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.service_binding;

/// Port for persisting and querying service bindings.
interface IServiceBindingRepository {
  ServiceBinding[] findByApp(AppId appId, TenantId tenantId);
  ServiceBinding* findById(ServiceBindingId id, TenantId tenantId);
  ServiceBinding[] findByServiceInstance(ServiceInstanceId instanceId, TenantId tenantId);
  ServiceBinding[] findByTenant(TenantId tenantId);
  void save(ServiceBinding binding);
  void update(ServiceBinding binding);
  void remove(ServiceBindingId id, TenantId tenantId);
  void removeByApp(AppId appId, TenantId tenantId);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.ports.usecases.manage_service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface IManageServiceInstances {
  ServiceInstance[] listInstances(TenantId tenantId);
  ServiceInstance getInstance(TenantId tenantId, ServiceInstanceId id);
  /// Starts a create operation (completed immediately in synchronous mode).
  ServiceInstance provisionInstance(ProvisionServiceInstanceRequest request);
  /// Plan or parameter changes start an update operation.
  ServiceInstance updateInstance(UpdateServiceInstanceRequest request);
  /// Starts a delete operation; refused while bindings exist.
  void deprovisionInstance(TenantId tenantId, ServiceInstanceId id, UserId actor);
}

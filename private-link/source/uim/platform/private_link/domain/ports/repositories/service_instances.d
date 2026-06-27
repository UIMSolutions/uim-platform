/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.ports.repositories.service_instances;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Port: repository contract for ServiceInstance persistence.
interface ServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {
  bool existsByName(TenantId tenantId, string name);
  ServiceInstance findByName(TenantId tenantId, string name);
  ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status);
  ServiceInstance[] findByIaasProvider(TenantId tenantId, IaasProvider provider);
}

module uim.platform.private_link.domain.ports.repositories.service_bindings;

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.domain.ports.repositories.service_bindings;
import uim.platform.private_link;

// mixin(ShowModule!());

@safe:
/// Port: repository contract for ServiceBinding persistence.
interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {
  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
  ServiceBinding[] findByApplication(TenantId tenantId, string applicationId);
  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId);
}

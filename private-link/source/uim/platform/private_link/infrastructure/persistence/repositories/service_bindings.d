/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.repositories.service_bindings;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
class ServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {

  // #region ByServiceInstance
  size_t countByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return findByServiceInstance(tenantId, instanceId).length;
  }

  ServiceBinding[] filterByServiceInstance(ServiceBinding[] bindings, ServiceInstanceId instanceId) {
    return bindings.filter!(b => b.serviceInstanceId.value == instanceId.value).array;
  }

  ServiceBinding[] findByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    return filterByServiceInstance(findByTenant(tenantId), instanceId);
  }

  void removeByServiceInstance(TenantId tenantId, ServiceInstanceId instanceId) {
    findByServiceInstance(tenantId, instanceId).each!(b => remove(b));
  }
  // #endregion ByServiceInstance

  // #region ByApplication
  size_t countByApplication(TenantId tenantId, string applicationId) {
    return findByApplication(tenantId, applicationId).length;
  }

  ServiceBinding[] filterByApplication(ServiceBinding[] bindings, string applicationId) {
    return bindings.filter!(b => b.applicationId == applicationId).array;
  }

  ServiceBinding[] findByApplication(TenantId tenantId, string applicationId) {
    return filterByApplication(findByTenant(tenantId), applicationId);
  }

  void removeByApplication(TenantId tenantId, string applicationId) {
    findByApplication(tenantId, applicationId).each!(b => remove(b));
  }
  // #endregion ByApplication
  
}

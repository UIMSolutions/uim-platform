/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.infrastructure.persistence.repositories.service_instances;
import uim.platform.private_link;

mixin(ShowModule!());

@safe:
class ServiceInstanceRepository
    : TenantRepository!(ServiceInstance, ServiceInstanceId),
      IServiceInstanceRepository {

  bool existsByName(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(i => i.name == name);
  }

  ServiceInstance findByName(TenantId tenantId, string name) {
    foreach (i; findByTenant(tenantId)) {
      if (i.name == name)
        return i;
    }
    return ServiceInstance.init;
  }

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, InstanceStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ServiceInstance[] filterByStatus(ServiceInstance[] instances, InstanceStatus status) {
    return instances.filter!(i => i.status == status).array;
  }
  
  ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, InstanceStatus status) {
    findByStatus(tenantId, status).each!(i => remove(i));
  }
  // #endregion ByStatus

  // #region ByIaasProvider
  size_t countByIaasProvider(TenantId tenantId, IaasProvider provider) {
    return findByIaasProvider(tenantId, provider).length;
  }

  ServiceInstance[] filterByIaasProvider(ServiceInstance[] instances, IaasProvider provider) {
    return instances.filter!(i => i.iaasProvider == provider).array;
  }

  ServiceInstance[] findByIaasProvider(TenantId tenantId, IaasProvider provider) {
    return filterByIaasProvider(findByTenant(tenantId), provider);
  }

  void removeByIaasProvider(TenantId tenantId, IaasProvider provider) {
    findByIaasProvider(tenantId, provider).each!(i => remove(i));
  }
  // #endregion ByIaasProvider
  
}

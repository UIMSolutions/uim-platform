/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.service_bindings;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class ServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), IServiceBindingRepository {

  size_tt countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  ServiceBinding[] filterByProject(ServiceBinding[] bindings, string projectId) {
    return bindings.filter!(sb => sb.projectId.value == projectId).array;
  }

  ServiceBinding[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void removeByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!(sb => remove(sb));
  }

  size_t countByServiceName(TenantId tenantId, string serviceName) {
    return findByServiceName(tenantId, serviceName).length;
  }

  ServiceBinding[] filterByServiceName(ServiceBinding[] bindings, string serviceName) {
    return bindings.filter!(sb => sb.serviceName == serviceName).array;
  }

  ServiceBinding[] findByServiceName(TenantId tenantId, string serviceName) {
    return filterByServiceName(findByTenant(tenantId), serviceName);
  }

  size_t countByStatus(TenantId tenantId, BindingStatus status) {
    return findByStatus(tenantId, status).length;
  }
  
  ServiceBinding[] filterByStatus(ServiceBinding[] bindings, BindingStatus status) {
    return bindings.filter!(sb => sb.status == status).array;
  }
  
  override ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, BindingStatus status) {
    findByStatus(tenantId, status).each!(sb => remove(sb));
  }
  
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.service_bindings;

import uim.platform.buildcode;
mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : ServiceBindingRepository {
  private ServiceBinding[string] _store;

  override void save(ServiceBinding entity)                    { _store[entity.id.value] = entity; }
  override void update(ServiceBinding entity)                  { _store[entity.id.value] = entity; }
  override void remove(TenantId tenantId, ServiceBindingId id)   { _store.remove(id.value); }

  override ServiceBinding findById(TenantId tenantId, ServiceBindingId id) {
    if (id.value in _store) return _store[id.value];
    ServiceBinding sb; return sb;
  }

  override ServiceBinding[] findByTenant(TenantId tenantId) {
    ServiceBinding[] result;
    foreach (sb; _store.byValue)
      if (sb.tenantId == tenantId) result ~= sb;
    return result;
  }

  override ServiceBinding[] findByProject(TenantId tenantId, string projectId) {
    ServiceBinding[] result;
    foreach (sb; _store.byValue)
      if (sb.tenantId == tenantId && sb.projectId.value == projectId) result ~= sb;
    return result;
  }

  override ServiceBinding[] findByServiceName(TenantId tenantId, string serviceName) {
    ServiceBinding[] result;
    foreach (sb; _store.byValue)
      if (sb.tenantId == tenantId && sb.serviceName == serviceName) result ~= sb;
    return result;
  }

  override ServiceBinding[] findByStatus(TenantId tenantId, BindingStatus status) {
    ServiceBinding[] result;
    foreach (sb; _store.byValue)
      if (sb.tenantId == tenantId && sb.status == status) result ~= sb;
    return result;
  }
}

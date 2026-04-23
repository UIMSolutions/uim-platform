/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.alerts;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.alert;
// import uim.platform.hana.domain.ports.repositories.alerts;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryAlertRepository : MemoryTenantRepository!(Alert, AlertId), AlertRepository {
  bool existsById(AlertId id) {
    return findAll().any!(tenantId => (id in store[tenantId]) ? true : false);
  }

  Alert findById(AlertId id) {
    foreach (tenentId, alerts; store) {
      if (id in alerts)
        return alerts[id];
    }
    return Alert.init;
  }

  override Alert[] findByTenant(TenantId tenantId) {
    return store.filter!(a => a.tenantId == tenantId).array;
  }

  Alert[] findByInstance(InstanceId instanceId) {
    return findAll().map!(tenantId => findByInstance(tenantId, instanceId)).array.chain;          
  }

  Alert[] findByInstance(TenantId tenantId, InstanceId instanceId) {
    return findByTenant(tenantId).filter!(a => a.instanceId == instanceId).array;
  }

  Alert[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(a => a.status == AlertStatus.active).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  size_t countAll() {
    return findAll().map!(alerts => alerts.length).sum;
  }

  void remove(AlertId id) {
    foreach (tenantId, alerts; store) {
      if (id in alerts) {
        store[tenantId].remove(id);

        if (store[tenantId].isEmpty) store.remove(tenantId);
        return;
      }
    }
  }
}

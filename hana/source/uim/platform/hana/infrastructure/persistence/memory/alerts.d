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
class MemoryAlertRepository : AlertRepository {
  private Alert[] store;

  Alert findById(AlertId id) {
    foreach (ref a; store) {
      if (a.id == id)
        return a;
    }
    return Alert.init;
  }

  Alert[] findByTenant(TenantId tenantId) {
    return store.filter!(a => a.tenantId == tenantId).array;
  }

  Alert[] findByInstance(InstanceId instanceId) {
    return store.filter!(a => a.instanceId == instanceId).array;
  }

  Alert[] findActive(TenantId tenantId) {
    return store.filter!(a => a.tenantId == tenantId && a.status == AlertStatus.active).array;
  }

  void save(Alert a) {
    store ~= a;
  }

  void update(Alert a) {
    foreach (ref existing; store) {
      if (existing.id == a.id) {
        existing = a;
        return;
      }
    }
  }

  void remove(AlertId id) {
    store = store.filter!(a => a.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(a => a.tenantId == tenantId).array.length;
  }
}

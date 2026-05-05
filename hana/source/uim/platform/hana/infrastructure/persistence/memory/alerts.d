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

  size_t countByInstance(DatabaseInstanceId instanceId) {
    return findByInstance(instanceId).length;
  } 
  Alert[] filterByInstance(Alert[] alerts, DatabaseInstanceId instanceId) {
    return alerts.filter!(a => a.instanceId == instanceId).array;
  }
  Alert[] findByInstance(DatabaseInstanceId instanceId) {
    return findAll().map!(tenantId => findByInstance(tenantId, instanceId)).array.chain;          
  }
  void removeByInstance(DatabaseInstanceId instanceId) {
    findByInstance(instanceId).each!(entity => remove(entity));
  }

  size_t countActive(TenantId tenantId) {
    return findActive(tenantId).length;
  }
  Alert[] filterActive(Alert[] alerts) {
    return alerts.filter!(a => a.status == AlertStatus.active).array;
  }
  Alert[] findActive(TenantId tenantId) {
    return findByTenant(tenantId).filter!(a => a.status == AlertStatus.active).array;
  }
  void removeActive(TenantId tenantId) {
    findActive(tenantId).each!(entity => remove(entity));
  }

}

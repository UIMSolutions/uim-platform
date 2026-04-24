/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.data_lakes;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.data_lake;
// import uim.platform.hana.domain.ports.repositories.data_lakes;

// import std.algorithm : filter;
// import std.array : array;

import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryDataLakeRepository : DataLakeRepository {
  private DataLake[] store;

  DataLake findById(DataLakeId id) {
    foreach (d; findAll) {
      if (d.id == id)
        return d;
    }
    return DataLake.init;
  }

  DataLake[] findByTenant(TenantId tenantId) {
    return findAll().filter!(d => d.tenantId == tenantId).array;
  }

  DataLake[] findByInstance(InstanceId instanceId) {
    return findAll().filter!(d => d.instanceId == instanceId).array;
  }

  void save(DataLake d) {
    store ~= d;
  }

  void update(DataLake d) {
    foreach (existing; findAll) {
      if (existing.id == d.id) {
        existing = d;
        return;
      }
    }
  }

  void remove(DataLakeId id) {
    store = findAll().filter!(d => d.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return findAll().filter!(d => d.tenantId == tenantId).array.length;
  }
}

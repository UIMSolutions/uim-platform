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
class MemoryDataLakeRepository : TenantRepository!(DataLake, DataLakeId), DataLakeRepository {


  size_t countByInstance(InstanceId instanceId) {
    return findByInstance(instanceId).length;
  }
  DataLake[] filterByInstance(DataLake[] dataLakes, InstanceId instanceId) {
    return dataLakes.filter!(d => d.instanceId == instanceId).array;
  }
  DataLake[] findByInstance(InstanceId instanceId) {
    return filterByInstance(findAll(), instanceId);
  }
  void removeByInstance(InstanceId instanceId) {
    findByInstance(instanceId).each!(d => remove(d.id));
  }

}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.database_users;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.database_user;
// import uim.platform.hana.domain.ports.repositories.database_users;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryDatabaseUserRepository : TenantRepository!(DatabaseUser, DatabaseUserId), DatabaseUserRepository {

  size_t countByInstance(InstanceId instanceId) {
    return findByInstance(instanceId).length;
  }

  DatabaseUser[] filterByInstance(DatabaseUser[] users, InstanceId instanceId) {
    return users.filter!(u => u.instanceId == instanceId).array;
  }

  DatabaseUser[] findByInstance(InstanceId instanceId) {
    return filterByInstance(findAll(), instanceId);
  }

  void removeByInstance(InstanceId instanceId) {
    findByInstance(instanceId).each!(u => remove(u));

  }
}

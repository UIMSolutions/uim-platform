/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.user;

// import uim.platform.identity.directory.domain.entities.user;
// import uim.platform.identity.directory.domain.types;
// import uim.platform.identity.directory.domain.ports.repositories.users;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
// import std.algorithm : canFind;
// import std.string : toLower, indexOf;

/// In-memory adapter for user persistence.
class MemoryUserRepository : UserRepository {

  bool existsByUserName(TenantId tenantId, string userName) {
    return findAll().any!(u => u.tenantId == tenantId && u.userName == userName);
  }

  User findByUserName(TenantId tenantId, string userName) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.userName == userName)
        return u;
    }
    return User.init;
  }

  bool existsByExternalId(TenantId tenantId, string externalId) {
    return findAll().any!(u => u.tenantId == tenantId && u.externalId == externalId);
  }

  User findByExternalId(TenantId tenantId, string externalId) {
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.externalId == externalId)
        return u;
    }
    return User.init;
  }

  size_t countByUserName(TenantId tenantId, string userName) {
    size_t count;
    foreach (u; findAll()) {
      if (u.tenantId == tenantId && u.userName == userName)
        count++;
    }
    return count;
  }

  User[] filterByUserName(User[] users, string userName) {
    return users.filter!(u => u.userName == userName).array;
  }

  User[] findByUserName(TenantId tenantId, string userName) {
    return filterByUserName(findByTenant(tenantId), userName);
  }

  void removeByUserName(TenantId tenantId, string userName) {
    findByUserName(tenantId, userName).each!(u => remove(u));
  }

  size_t countByEmail(TenantId tenantId, string email) {
    return findByEmail(tenantId, email).length;
  }

  User[] filterByEmail(User[] users, string email) {
    return users.filter!(u => u.emails.canFind!(e => e.value == email)).array;
  }

  User[] findByEmail(TenantId tenantId, string email) {
    return filterByEmail(findByTenant(tenantId), email);
  }

  void removeByEmail(TenantId tenantId, string email) {
    findByEmail(tenantId, email).each!(u => remove(u));
  }

  size_t countByGroupId(TenantId tenantId, GroupId groupId) {
    return findByGroupId(groupId).length;
  }

  User[] filterByGroupId(User[] users, GroupId groupId) {
    return users.filter!(u => u.groupIds.canFind(groupId)).array;
  }

  User[] findByGroupId(GroupId groupId) {
    return findAll().filter!(u => u.groupIds.canFind(groupId)).array;
  }

  User[] search(TenantId tenantId, string filter, uint offset = 0, uint limit = 100) {
    User[] result;
    auto lowerFilter = filter.toLower();
    uint idx;
    foreach (u; findByTenant(tenantId)) {
      // Simple filter: match against userName, displayName, emails
      bool matches = false;
      if (u.userName.toLower().indexOf(lowerFilter) >= 0)
        matches = true;
      else if (u.displayName.toLower().indexOf(lowerFilter) >= 0)
        matches = true;
      else if (u.name.givenName.toLower().indexOf(lowerFilter) >= 0)
        matches = true;
      else if (u.name.familyName.toLower().indexOf(lowerFilter) >= 0)
        matches = true;
      else {
        foreach (e; u.emails) {
          if (e.value.toLower().indexOf(lowerFilter) >= 0) {
            matches = true;
            break;
          }
        }
      }

      if (matches) {
        if (idx >= offset && result.length < limit)
          result ~= u;
        idx++;
      }
    }
    return result;
  }

}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.repositories.users;
// import uim.platform.identity_directory.domain.entities.user;

// import uim.platform.identity_directory.domain.ports.repositories.users;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
// import std.algorithm : canFind;
// import std.string : toLower, indexOf;
/// In-memory adapter for user persistence.
class MemoryUserRepository : TenantRepository!(IDUser, UserId), UserRepository {

  bool existsByUserName(TenantId tenantId, string userName) {
    return findByTenant(tenantId).any!(u => u.userName == userName);
  }

  IDUser findByUserName(TenantId tenantId, string userName) {
    foreach (u; findByTenant(tenantId)) {
      if (u.userName == userName)
        return u;
    }
    return IDUser.init;
  }

  void removeByUserName(TenantId tenantId, string userName) {
    auto user = findByUserName(tenantId, userName);
    if (user.userId.value != 0)
      remove(user);
  }

  bool existsByExternalId(TenantId tenantId, string externalId) {
    return findByTenant(tenantId).any!(u => u.externalId == externalId);
  }

  IDUser findByExternalId(TenantId tenantId, string externalId) {
    foreach (u; findByTenant(tenantId)) {
      if (u.externalId == externalId)
        return u;
    }
    return IDUser.init;
  }
  void removeByExternalId(TenantId tenantId, string externalId) {
    auto user = findByExternalId(tenantId, externalId);
    if (user.userId.value != 0)
      remove(user);
  }

  size_t countByEmail(TenantId tenantId, string email) {
    return findByEmail(tenantId, email).length;
  }

  IDUser[] filterByEmail(IDUser[] users, string email) {
    return users.filter!(u => u.emails.canFind!(e => e.value == email)).array;
  }

  IDUser[] findByEmail(TenantId tenantId, string email) {
    return filterByEmail(findByTenant(tenantId), email);
  }

  void removeByEmail(TenantId tenantId, string email) {
    findByEmail(tenantId, email).each!(u => remove(u));
  }

  size_t countByGroup(TenantId tenantId, GroupId groupId) {
    return findByGroup(tenantId, groupId).length;
  }

  IDUser[] filterByGroup(IDUser[] users, GroupId groupId) {
    return users.filter!(u => u.groupIds.canFind(groupId)).array;
  }

  IDUser[] findByGroup(TenantId tenantId, GroupId groupId) {
    return findByTenant(tenantId).filter!(u => u.groupIds.canFind(groupId)).array;
  }

  void removeByGroup(TenantId tenantId, GroupId groupId) {
    findByGroup(tenantId, groupId).each!(u => remove(u));
  }

  IDUser[] search(TenantId tenantId, string filter) { // }, size_t offset = 0, size_t limit = 100) {
    IDUser[] result;
    auto lowerFilter = filter.toLower();
    size_t idx;
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
        // if (idx >= offset && result.length < limit)
          result ~= u;
        // idx++;
      }
    }
    return result;
  }

}

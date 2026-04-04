/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.persistence.memory.user_repo;

import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory.domain.ports.repositories.users;

// import std.algorithm : canFind;
// import std.string : toLower, indexOf;

/// In-memory adapter for user persistence.
class MemoryUserRepository : UserRepository
{
  private User[UserId] store;

  User findById(UserId id)
  {
    if (auto p = id in store)
      return *p;
    return User.init;
  }

  User findByUserName(TenantId tenantId, string userName)
  {
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId && u.userName == userName)
        return u;
    }
    return User.init;
  }

  User findByExternalId(TenantId tenantId, string externalId)
  {
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId && u.externalId == externalId)
        return u;
    }
    return User.init;
  }

  User[] findByEmail(TenantId tenantId, string email)
  {
    User[] result;
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId)
      {
        foreach (e; u.emails)
        {
          if (e.value == email)
          {
            result ~= u;
            break;
          }
        }
      }
    }
    return result;
  }

  User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    User[] result;
    uint idx;
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId)
      {
        if (idx >= offset && result.length < limit)
          result ~= u;
        idx++;
      }
    }
    return result;
  }

  User[] findByGroupId(GroupId groupId)
  {
    User[] result;
    foreach (u; store.byValue())
    {
      if (u.groupIds.canFind(groupId))
        result ~= u;
    }
    return result;
  }

  User[] search(TenantId tenantId, string filter, uint offset = 0, uint limit = 100)
  {
    User[] result;
    auto lowerFilter = filter.toLower();
    uint idx;
    foreach (u; store.byValue())
    {
      if (u.tenantId != tenantId)
        continue;

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
      else
      {
        foreach (e; u.emails)
        {
          if (e.value.toLower().indexOf(lowerFilter) >= 0)
          {
            matches = true;
            break;
          }
        }
      }

      if (matches)
      {
        if (idx >= offset && result.length < limit)
          result ~= u;
        idx++;
      }
    }
    return result;
  }

  void save(User user)
  {
    store[user.id] = user;
  }

  void update(User user)
  {
    store[user.id] = user;
  }

  void remove(UserId id)
  {
    store.remove(id);
  }

  ulong countByTenant(TenantId tenantId)
  {
    ulong count;
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId)
        count++;
    }
    return count;
  }
}

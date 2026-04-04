/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.persistence.memory.user_repo;

// import uim.platform.identity_authentication.domain.entities.user;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.repositories.user;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for user persistence (swap for DB adapter in production).
class MemoryUserRepository : UserRepository
{
  private User[UserId] store;

  bool existsById(UserId id)
  {
    return (id in store) ? true : false;
  }

  User findById(UserId id)
  {
    if (existsById(id))
      return store[id];
    return User.init;
  }

  User findByEmail(TenantId tenantId, string email)
  {
    foreach (u; store.byValue())
    {
      if (u.tenantId == tenantId && u.email == email)
        return u;
    }
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
    return store.byValue().filter!(u => u.groupIds.canFind(groupId)).array;
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
    return store.byValue().count!(u => u.tenantId == tenantId);
  }
}

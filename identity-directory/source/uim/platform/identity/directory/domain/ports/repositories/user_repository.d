/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.users;

import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — user persistence (SCIM 2.0 compliant).
interface UserRepository {
  User findById(UserId id);
  User findByUserName(TenantId tenantId, string userName);
  User findByExternalId(TenantId tenantId, string externalId);
  User[] findByEmail(TenantId tenantId, string email);
  User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
  User[] findByGroupId(GroupId groupId);
  User[] search(TenantId tenantId, string filter, uint offset = 0, uint limit = 100);
  void save(User user);
  void update(User user);
  void remove(UserId id);
  size_t countByTenant(TenantId tenantId);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.ports.repositories.users;

import uim.platform.identity.directory.domain.entities.user;
import uim.platform.identity.directory.domain.types;

/// Port: outgoing — user persistence (SCIM 2.0 compliant).
interface UserRepository : ITenantRepository!(User, UserId) {

  bool existsByUserName(TenantId tenantId, string userName);
  User findByUserName(TenantId tenantId, string userName);
  void removeByUserName(TenantId tenantId, string userName);

  bool existsByExternalId(TenantId tenantId, string externalId);
  User findByExternalId(TenantId tenantId, string externalId);
  void removeByExternalId(TenantId tenantId, string externalId);

  size_t countByEmail(TenantId tenantId, string email);
  User[] findByEmail(TenantId tenantId, string email);
  void removeByEmail(TenantId tenantId, string email);

  size_t countByGroupId(GroupId groupId);
  User[] findByGroupId(GroupId groupId);
  void removeByGroupId(GroupId groupId);

  User[] search(TenantId tenantId, string filter, size_t offset = 0, size_t limit = 100);

}

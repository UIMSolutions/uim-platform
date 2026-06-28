/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.infrastructure.persistence.memory.tenant_users;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:
class MemoryTenantUserRepository
    : TenantRepository!(TenantUser, TenantUserId),
      TenantUserRepository {

  TenantUser[] findByRole(TenantId tenantId, TenantUserRole role) {
    TenantUser[] result;
    foreach (item; find(tenantId)) {
      if (item.role == role) result ~= item;
    }
    return result;
  }

  TenantUser[] findByEmail(TenantId tenantId, string email) {
    TenantUser[] result;
    foreach (item; find(tenantId)) {
      if (item.email == email) result ~= item;
    }
    return result;
  }
}

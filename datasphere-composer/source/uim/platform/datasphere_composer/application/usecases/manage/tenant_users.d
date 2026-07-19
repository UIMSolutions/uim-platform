/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.tenant_users;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageTenantUsersUseCase {
  private TenantUserRepository repo;

  this(TenantUserRepository repo) { this.repo = repo; }

  CommandResult create(CreateTenantUserRequest r) {
    TenantUser u;
    u.id = TenantUserId(r.id.length > 0 ? r.id : currentTimestamp());
    u.tenantId = TenantId(r.tenantId);
    u.email = r.email;
    u.firstName = r.firstName;
    u.lastName = r.lastName;
    u.role = r.role.length > 0 ? cast(TenantUserRole) r.role : TenantUserRole.viewer;
    u.active = true;
    u.externalUserId = r.externalUserId;
    initEntity(u);

    auto err = ComposerValidator.validateTenantUser(u);
    if (err !is null) return CommandResult(false, u.id.value, err);

    repo.save(u);
    return CommandResult(true, u.id.value, null);
  }

  TenantUser[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  TenantUser getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), TenantUserId(id));
  }

  CommandResult update(UpdateTenantUserRequest r) {
    auto u = repo.findById(TenantId(r.tenantId), TenantUserId(r.id));
    if (u.isNull) return CommandResult(false, r.id, "User not found");

    if (r.firstName.length > 0) u.firstName = r.firstName;
    if (r.lastName.length > 0)  u.lastName = r.lastName;
    if (r.role.length > 0)      u.role = cast(TenantUserRole) r.role;
    u.active = r.active;

    repo.update(u);
    return CommandResult(true, u.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto u = repo.findById(TenantId(tenantId), TenantUserId(id));
    if (u.isNull) return CommandResult(false, id, "User not found");
    repo.remove(TenantId(tenantId), TenantUserId(id));
    return CommandResult(true, id, null);
  }
}

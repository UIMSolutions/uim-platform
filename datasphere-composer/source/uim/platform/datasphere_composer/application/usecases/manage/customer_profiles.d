/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.customer_profiles;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageCustomerProfilesUseCase {
  private CustomerProfileRepository repo;

  this(CustomerProfileRepository repo) { this.repo = repo; }

  CustomerProfile[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  CustomerProfile getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), CustomerProfileId(id));
  }

  CustomerProfile[] searchByEmail(TenantId tenantId, string email) {
    return repo.findByEmail(TenantId(tenantId), email);
  }

  CustomerProfile[] searchByExternalId(TenantId tenantId, string externalId) {
    return repo.findByExternalId(TenantId(tenantId), externalId);
  }

  /// Used internally by composition runs to persist a unified profile.
  CommandResult upsert(CustomerProfile profile) {
    auto existing = repo.findById(profile.tenantId, profile.id);
    if (existing.isNull) {
      repo.save(profile);
    } else {
      repo.update(profile);
    }
    return CommandResult(true, profile.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto p = repo.findById(TenantId(tenantId), CustomerProfileId(id));
    if (p.isNull) return CommandResult(false, id, "Profile not found");
    repo.remove(TenantId(tenantId), CustomerProfileId(id));
    return CommandResult(true, id, null);
  }
}

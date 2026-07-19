/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.application.usecases.manage.providers;
import uim.platform.marketrates;

mixin(ShowModule!());

@safe:

class ManageProvidersUseCase {
  private ProviderRepository repo;

  this(ProviderRepository repo) {
    this.repo = repo;
  }

  CommandResult createProvider(CreateProviderRequest req) {
    if (req.code.length == 0)
      return CommandResult(false, "", "Provider code is required");
    if (req.name.isEmpty)
      return CommandResult(false, "", "Provider name is required");
    if (repo.codeExists(req.tenantId, req.code))
      return CommandResult(false, "", "A provider with this code already exists");

    auto p = Provider(req.tenantId); //, UserId("test-user"));
    p.code         = req.code;
    p.name         = req.name;
    p.description  = req.description;
    p.contactEmail = req.contactEmail;
    p.isActive     = true;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  Provider getById(TenantId tenantId, ProviderId id) {
    return repo.findById(tenantId, id);
  }

  Provider[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Provider[] listActive(TenantId tenantId) {
    return repo.findActive(tenantId);
  }

  CommandResult updateProvider(UpdateProviderRequest req) {
    auto p = repo.findById(req.tenantId, req.providerId);
    if (p.isNull)
      return CommandResult(false, "", "Provider not found");

    p.name         = req.name;
    p.description  = req.description;
    p.contactEmail = req.contactEmail;
    p.isActive     = req.isActive;
    p.updatedAt    = currentTimestamp;

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult deleteProvider(TenantId tenantId, ProviderId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return CommandResult(false, "", "Provider not found");

    repo.remove(p);
    return CommandResult(true, p.id.value, "");
  }
}

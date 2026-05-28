/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_providers;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageDataProvidersUseCase {
  private DataProviderRepository repo;

  this(DataProviderRepository repo) { this.repo = repo; }

  CommandResult create(CreateDataProviderRequest r) {
    auto err = ComposerValidator.validateDataProvider(DataProvider(
      DataProviderId(r.id), TenantId(r.tenantId), r.name, r.description));
    if (err !is null) return CommandResult(false, r.id, err);

    DataProvider p;
    p.id = DataProviderId(r.id.length > 0 ? r.id : currentTimestamp());
    p.tenantId = TenantId(r.tenantId);
    p.name = r.name;
    p.description = r.description;
    p.systemType = r.systemType;
    p.connectionUrl = r.connectionUrl;
    p.region = r.region;
    p.status = DataProviderStatus.active;
    p.metadata = r.metadata;
    initEntity(p);

    repo.save(p);
    return CommandResult(true, p.id.value, null);
  }

  DataProvider[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  DataProvider getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), DataProviderId(id));
  }

  CommandResult update(UpdateDataProviderRequest r) {
    auto p = repo.findById(TenantId(r.tenantId), DataProviderId(r.id));
    if (p.isNull) return CommandResult(false, r.id, "Provider not found");

    if (r.name.length > 0)          p.name = r.name;
    if (r.description.length > 0)   p.description = r.description;
    if (r.connectionUrl.length > 0)  p.connectionUrl = r.connectionUrl;
    if (r.region.length > 0)         p.region = r.region;
    if (r.status.length > 0) {
      import std.conv : to;
      try { p.status = r.status.to!DataProviderStatus; } catch (Exception) {}
    }

    repo.update(p);
    return CommandResult(true, p.id.value, null);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto p = repo.findById(TenantId(tenantId), DataProviderId(id));
    if (p.isNull) return CommandResult(false, id, "Provider not found");
    repo.remove(TenantId(tenantId), DataProviderId(id));
    return CommandResult(true, id, null);
  }
}

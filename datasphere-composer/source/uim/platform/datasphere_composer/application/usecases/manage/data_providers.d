/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.data_providers;

import uim.platform.datasphere_composer;
import std.conv : to;

mixin(ShowModule!());

@safe:
class ManageDataProvidersUseCase {
  protected IDataProviderRepository repo;

  this(IDataProviderRepository repo) { this.repo = repo; }

  UsecaseResult create(CreateDataProviderRequest r) {
    DataProvider p;
    p.createEntity(r.tenantId);
    if (!r.id.isNull)
      p.id = r.id;
    p.tenantId = r.tenantId;
    p.name = r.name;
    p.description = r.description;
    p.systemType = r.systemType;
    p.connectionUrl = r.connectionUrl;
    p.region = r.region;
    p.status = DataProviderStatus.active;
    p.metadata = r.metadata;

    auto err = ComposerValidator.validateDataProvider(p);
    if (err !is null)
      return UsecaseResult(false, p.id.value, err);

    repo.save(p);
    return UsecaseResult(true, p.id.value, null);
  }

  DataProvider[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  DataProvider getById(TenantId tenantId, DataProviderId id) {
    return repo.findById(tenantId, id);
  }

  DataProvider getById(TenantId tenantId, string id) {
    return getById(tenantId, DataProviderId(id));
  }

  UsecaseResult update(UpdateDataProviderRequest r) {
    auto p = repo.findById(r.tenantId, r.id);
    if (p.isNull) return UsecaseResult(false, r.id.value, "Provider not found");

    if (r.name.length > 0)          p.name = r.name;
    if (r.description.length > 0)   p.description = r.description;
    if (r.connectionUrl.length > 0) p.connectionUrl = r.connectionUrl;
    if (r.region.length > 0)        p.region = r.region;
    if (r.status.length > 0) {
      try {
        p.status = r.status.to!DataProviderStatus;
      } catch (Exception) {
        return UsecaseResult(false, r.id.value, "Invalid provider status");
      }
    }

    repo.update(p);
    return UsecaseResult(true, p.id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, DataProviderId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull) return UsecaseResult(false, id.value, "Provider not found");
    repo.remove(p);
    return UsecaseResult(true, id.value, null);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    return remove(tenantId, DataProviderId(id));
  }
}

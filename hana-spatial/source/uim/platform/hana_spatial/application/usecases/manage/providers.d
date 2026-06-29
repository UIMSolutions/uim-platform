/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana_spatial.application.usecases.manage.providers;

import uim.platform.hana_spatial;


// mixin(ShowModule!());

@safe:
class ManageProvidersUseCase {
  private ProviderRepository repo;

  this(ProviderRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateProviderRequest r) {
    auto err = SpatialValidator.validateId(r.id);
    if (err.length > 0) return CommandResult(false, "", err);
    err = SpatialValidator.validateName(r.name);
    if (err.length > 0) return CommandResult(false, "", err);

    Provider provider;
    provider.initEntity(r.tenantId);
    provider.id = ProviderId(r.id);
    provider.name = r.name;
    provider.description = r.description;
    provider.apiKey = r.apiKey;
    provider.baseUrl = r.baseUrl;
    provider.supportsGeocoding = r.supportsGeocoding;
    provider.supportsRouting = r.supportsRouting;
    provider.supportsMapping = r.supportsMapping;
    provider.supportsIsoline = r.supportsIsoline;
    provider.supportsPoi = r.supportsPoi;
    provider.supportedRegions = r.supportedRegions;
    provider.config = r.config;
    provider.status = ProviderStatus.active;
    try {
      provider.type = r.type.to!ProviderType;
    } catch (Exception) {
      provider.type = ProviderType.custom;
    }

    repo.save(provider);
    return CommandResult(true, provider.id.value, "");
  }

  CommandResult update(UpdateProviderRequest r) {
    auto existing = repo.find(r.tenantId, ProviderId(r.id));
    if (existing.isNull)
      return CommandResult(false, "", "Provider not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.apiKey = r.apiKey;
    existing.baseUrl = r.baseUrl;
    existing.supportsGeocoding = r.supportsGeocoding;
    existing.supportsRouting = r.supportsRouting;
    existing.supportsMapping = r.supportsMapping;
    existing.supportsIsoline = r.supportsIsoline;
    existing.supportsPoi = r.supportsPoi;
    existing.updatedAt = currentTimestamp;
    try {
      existing.status = r.status.to!ProviderStatus;
    } catch (Exception) {}

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  Provider getById(TenantId tenantId, string id) {
    return repo.findById(tenantId, ProviderId(id));
  }

  Provider[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult remove(TenantId tenantId, string id) {
    auto existing = repo.findById(tenantId, ProviderId(id));
    if (existing.isNull)
      return CommandResult(false, "", "Provider not found");
    repo.remove(tenantId, ProviderId(id));
    return CommandResult(true, id, "");
  }
}

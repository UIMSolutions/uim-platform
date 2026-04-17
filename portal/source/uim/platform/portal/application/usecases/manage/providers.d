/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.providers;

// import uim.platform.portal.domain.entities.content_provider;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.providers;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageProvidersUseCase : UIMUseCase {
  private ProviderRepository providerRepo;

  this(ProviderRepository providerRepo) {
    this.providerRepo = providerRepo;
  }

  ProviderResponse createProvider(CreateProviderRequest req) {
    if (req.name.length == 0)
      return ProviderResponse("", "Provider name is required");

    ContentProvider provider;
    with (provider) {
      providerId = randomUUID();
      tenantId = req.tenantId;
      name = req.name;
      description = req.description;
      providerType = req.providerType;
      contentEndpointUrl = req.contentEndpointUrl;
      authToken = req.authToken;
      active = true; // new providers are active by default
      catalogIds = null; // initially not associated with any catalogs
      createdAt = Clock.currStdTime();
      updatedAt = createdAt;
    }
    providerRepo.save(provider);
    return ProviderResponse(provider.providerId, "");
  }

  ContentProvider getProvider(ProviderId id) {
    return providerRepo.findById(id);
  }

  ContentProvider[] listProviders(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return providerRepo.findByTenant(tenantId, offset, limit);
  }

  string updateProvider(UpdateProviderRequest req) {
    if (!providerRepo.existsById(req.providerId))
      return "Content provider not found";

    auto provider = providerRepo.findById(req.providerId);
    provider.name = req.name.length > 0 ? req.name : provider.name;
    provider.description = req.description;
    provider.contentEndpointUrl = req.contentEndpointUrl.length > 0
      ? req.contentEndpointUrl : provider.contentEndpointUrl;
    provider.authToken = req.authToken.length > 0 ? req.authToken : provider.authToken;
    provider.active = req.active;
    provider.updatedAt = Clock.currStdTime();
    providerRepo.update(provider);
    return "";
  }

  string deleteProvider(ProviderId id) {
    if (!providerRepo.existsById(id))
      return "Content provider not found";

    providerRepo.remove(id);
    return "";
  }
}

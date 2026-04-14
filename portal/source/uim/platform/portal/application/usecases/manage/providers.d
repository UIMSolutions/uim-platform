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

    auto now = Clock.currStdTime();
    auto id = randomUUID();
    auto provider = ContentProvider(id, req.tenantId, req.name, req.description,
      req.providerType, req.contentEndpointUrl, req.authToken, true, // active
      [], // catalogIds
      now, now,);
    providerRepo.save(provider);
    return ProviderResponse(id, "");
  }

  ContentProvider getProvider(ProviderId id) {
    return providerRepo.findById(id);
  }

  ContentProvider[] listProviders(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return providerRepo.findByTenant(tenantId, offset, limit);
  }

  string updateProvider(UpdateProviderRequest req) {
    auto provider = providerRepo.findById(req.providerId);
    if (provider == ContentProvider.init)
      return "Content provider not found";

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
    auto provider = providerRepo.findById(id);
    if (provider == ContentProvider.init)
      return "Content provider not found";

    providerRepo.remove(id);
    return "";
  }
}

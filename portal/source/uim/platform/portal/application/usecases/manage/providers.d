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


// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageProvidersUseCase { // TODO: UIMUseCase {
  private ProviderRepository providerRepo;

  this(ProviderRepository providerRepo) {
    this.providerRepo = providerRepo;
  }

  ProviderResponse createProvider(CreateProviderRequest req) {
    if (req.name.length == 0)
      return ProviderResponse(ProviderResponseId(""), "Provider name is required");

    auto provider = ContentProvider(req.tenantId);
    with (provider) {
      name = req.name;
      description = req.description;
      providerType = req.providerType;
      contentEndpointUrl = req.contentEndpointUrl;
      authToken = req.authToken;
      active = true; // new providers are active by default
      catalogIds = null; // initially not associated with any catalogs
    }
    providerRepo.save(provider);
    return ProviderResponse(provider.providerId, "");
  }

  ContentProvider getProvider(ProviderId id) {
    return providerRepo.findById(tenantId, id);
  }

  ContentProvider[] listProviders(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return providerRepo.findByTenant(tenantId, offset, limit);
  }

  CommandResult updateProvider(UpdateProviderRequest req) {
    if (!providerRepo.existsById(req.tenantId, req.providerId))
      return CommandResult(false, "", "Content provider not found");

    auto provider = providerRepo.findById(req.tenantId, req.providerId);
    with (provider) {
      name = req.name.length > 0 ? req.name : name;
      description = req.description;
      contentEndpointUrl = req.contentEndpointUrl.length > 0 ? req.contentEndpointUrl : contentEndpointUrl;
      authToken = req.authToken.length > 0 ? req.authToken : authToken;
      active = req.active;
      updatedAt = currentTimestamp();
    }
    providerRepo.update(provider);
    return CommandResult(true, provider.providerId.value, "Content provider updated successfully.");
  }

  CommandResult deleteProvider(TenantId tenantId, ProviderId id) {
    auto provider = providerRepo.findById(tenantId, id);
     if (provider.isNull)
      return CommandResult(false, "", "Content provider not found");  

    providerRepo.remove(provider);
    return CommandResult(true, provider.id.value, "Content provider deleted successfully.");
  }
}

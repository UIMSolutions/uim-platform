/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.external_content_providers;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.external_content_provider;
// import uim.platform.workzone.domain.ports.repositories.external_content_providers;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageExternalContentProvidersUseCase { // TODO: UIMUseCase {
  private ExternalContentProviderRepository repo;

  this(ExternalContentProviderRepository repo) {
    this.repo = repo;
  }

  CommandResult createProvider(CreateExternalContentProviderRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "", "Provider name is required");

    auto now = Clock.currStdTime();
    auto p = ExternalContentProvider();
    p.id = randomUUID();
    p.tenantId = req.tenantId;
    p.name = req.name;
    p.description = req.description;
    p.providerType = req.providerType;
    p.status = ProviderStatus.disconnected;
    p.endpointUrl = req.endpointUrl;
    p.authType = req.authType;
    p.authConfig = req.authConfig;
    p.contentTypes = req.contentTypes;
    p.refreshIntervalSec = req.refreshIntervalSec;
    p.createdAt = now;
    p.updatedAt = now;

    repo.save(p);
    return CommandResult(true, p.id.value, "");
  }

  ExternalContentProvider getProvider(TenantId tenantId, ExternalContentProviderId id) {
    return repo.findById(tenantId, id);
  }

  ExternalContentProvider[] listProviders(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateProvider(UpdateExternalContentProviderRequest req) {
    auto p = repo.findById(req.tenantId, req.id);
    if (p.isNull)
      return CommandResult(false, "", "Provider not found");

    if (req.name.length > 0)
      p.name = req.name;
    if (req.description.length > 0)
      p.description = req.description;
    if (req.endpointUrl.length > 0)
      p.endpointUrl = req.endpointUrl;
    p.status = req.status;
    p.updatedAt = Clock.currStdTime();

    repo.update(p);
    return CommandResult(true, p.id.value, "");
  }

  CommandResult deleteProvider(TenantId tenantId, ExternalContentProviderId id) {
    auto p = repo.findById(tenantId, id);
    if (p.isNull)
      return CommandResult(false, "", "Provider not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}

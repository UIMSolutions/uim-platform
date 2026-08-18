/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.application.usecases.manage.destinations;

// import uim.platform.integration_automation.domain.ports.repositories.systems;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
class ManageDestinationsUseCase {
  protected IDestinationRepository repo;
  private ISystemRepository systemRepo;

  this(IDestinationRepository repo, ISystemRepository systemRepo) {
    this.repo = repo;
    this.systemRepo = systemRepo;
  }

  UsecaseResult createDestination(CreateDestinationRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.name.isEmpty)
      return UsecaseResult(false, "", "Destination name is required");
    if (req.url.length == 0)
      return UsecaseResult(false, "", "URL is required");

    // Ensure unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return UsecaseResult(false, "", "Destination with this name already exists");

    // Validate linked system if provided
    if (!req.connectionId.isNull) {
      auto sys = systemRepo.findById(req.tenantId, req.connectionId);
      if (sys.isNull)
        return UsecaseResult(false, "", "Linked system not found");
    }

    auto dest = Destination(req.tenantId); //, req.createdBy);
    dest.name = req.name;
    dest.description = req.description;
    dest.systemId = req.connectionId;
    dest.destinationType = req.destinationType;
    dest.url = req.url;
    dest.authenticationType = req.authenticationType;
    dest.proxyType = req.proxyType;
    dest.cloudConnectorLocationId = req.cloudConnectorLocationId;
    dest.user = req.user;
    dest.tokenServiceUrl = req.tokenServiceUrl;
    dest.tokenServiceUser = req.tokenServiceUser;
    dest.audience = req.audience;
    dest.scope_ = req.scope_;
    dest.isEnabled = true;

    repo.save(dest);
    return UsecaseResult(true, dest.id.value, "");
  }

  Destination getDestination(TenantId tenantId, DestinationId id) {
    return repo.findById(tenantId, id);
  }

  Destination[] listDestinations(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Destination[] listBySystem(TenantId tenantId, SystemConnectionId systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  Destination[] listEnabled(TenantId tenantId) {
    return repo.findEnabled(tenantId);
  }

  UsecaseResult updateDestination(UpdateDestinationRequest req) {
    if (req.destinationId.isNull)
      return UsecaseResult(false, "", "Destination ID is required");
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.tenantId, req.destinationId);
    if (existing.isNull)
      return UsecaseResult(false, "", "Destination not found");

    auto updated = existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (!req.connectionId.isNull)
      updated.connectionId = req.connectionId;
    updated.destinationType = req.destinationType;
    if (req.url.length > 0)
      updated.url = req.url;
    updated.authenticationType = req.authenticationType;
    updated.proxyType = req.proxyType;
    if (req.cloudConnectorLocationId.length > 0)
      updated.cloudConnectorLocationId = req.cloudConnectorLocationId;
    if (req.user.length > 0)
      updated.user = req.user;
    if (req.tokenServiceUrl.length > 0)
      updated.tokenServiceUrl = req.tokenServiceUrl;
    if (req.tokenServiceUser.length > 0)
      updated.tokenServiceUser = req.tokenServiceUser;
    if (req.audience.length > 0)
      updated.audience = req.audience;
    if (req.scope_.length > 0)
      updated.scope_ = req.scope_;
    updated.isEnabled = req.isEnabled;
    updated.updatedAt = currentTimestamp();

    repo.update(updated);
    return UsecaseResult(true, updated.id.value, "");
  }

  UsecaseResult deleteDestination(TenantId tenantId, DestinationId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Destination not found");

    repo.remove(existing);
    return UsecaseResult(true, existing.id.value, "");
  }
}

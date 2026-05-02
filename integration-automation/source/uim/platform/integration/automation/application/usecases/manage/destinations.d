/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.manage.destinations;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.destination;

// import uim.platform.integration.automation.domain.ports.repositories.destinations;
// import uim.platform.integration.automation.domain.ports.repositories.systems;
import uim.platform.integration.automation.domain.ports;
import uim.platform.integration.automation.application.dto;

class ManageDestinationsUseCase { // TODO: UIMUseCase {
  private DestinationRepository repo;
  private SystemRepository systemRepo;

  this(DestinationRepository repo, SystemRepository systemRepo) {
    this.repo = repo;
    this.systemRepo = systemRepo;
  }

  CommandResult createDestination(CreateDestinationRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Destination name is required");
    if (req.url.length == 0)
      return CommandResult(false, "", "URL is required");

    // Ensure unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult(false, "", "Destination with this name already exists");

    // Validate linked system if provided
    if (req.systemId.length > 0) {
      auto sys = systemRepo.findById(req.systemId, req.tenantId);
      if (sys.isNull)
        return CommandResult(false, "", "Linked system not found");
    }

    auto now = Clock.currStdTime();

    auto dest = Destination();
    dest.id = randomUUID();
    dest.tenantId = req.tenantId;
    dest.name = req.name;
    dest.description = req.description;
    dest.systemId = req.systemId;
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
    dest.createdBy = req.createdBy;
    dest.createdAt = now;
    dest.updatedAt = now;

    repo.save(dest);
    return CommandResult(dest.id, "");
  }

  Destination* getDestination(DestinationId tenantId, id tenantId) {
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

  CommandResult updateDestination(UpdateDestinationRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Destination ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing.isNull)
      return CommandResult(false, "", "Destination not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.systemId.length > 0)
      updated.systemId = req.systemId;
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
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult deleteDestination(DestinationId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Destination not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}

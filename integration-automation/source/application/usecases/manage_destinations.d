module application.usecases.manage_destinations;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.destination;
// import domain.ports.destination_repository;
// import domain.ports.system_repository;
import domain.ports;
import application.dto;

class ManageDestinationsUseCase {
  private DestinationRepository repo;
  private SystemRepository systemRepo;

  this(DestinationRepository repo, SystemRepository systemRepo) {
    this.repo = repo;
    this.systemRepo = systemRepo;
  }

  CommandResult createDestination(CreateDestinationRequest req) {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "Destination name is required");
    if (req.url.length == 0)
      return CommandResult("", "URL is required");

    // Ensure unique name per tenant
    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Destination with this name already exists");

    // Validate linked system if provided
    if (req.systemId.length > 0) {
      auto sys = systemRepo.findById(req.systemId, req.tenantId);
      if (sys is null)
        return CommandResult("", "Linked system not found");
    }

    auto now = Clock.currStdTime();

    auto dest = Destination();
    dest.id = randomUUID().toString();
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

  Destination* getDestination(DestinationId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  Destination[] listDestinations(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Destination[] listBySystem(TenantId tenantId, SystemId systemId) {
    return repo.findBySystem(tenantId, systemId);
  }

  Destination[] listEnabled(TenantId tenantId) {
    return repo.findEnabled(tenantId);
  }

  CommandResult updateDestination(UpdateDestinationRequest req) {
    if (req.id.length == 0)
      return CommandResult("", "Destination ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Destination not found");

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

  CommandResult deleteDestination(DestinationId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Destination not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

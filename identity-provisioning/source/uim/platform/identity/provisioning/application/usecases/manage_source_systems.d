module application.usecases.manage_source_systems;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.source_system;
import domain.ports.source_system_repository;
import uim.platform.xyz.application.dto;

class ManageSourceSystemsUseCase
{
  private SourceSystemRepository repo;

  this(SourceSystemRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createSourceSystem(CreateSourceSystemRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Source system with this name already exists");

    auto now = Clock.currStdTime();
    auto sys = SourceSystem();
    sys.id = randomUUID().toString();
    sys.tenantId = req.tenantId;
    sys.name = req.name;
    sys.description = req.description;
    sys.systemType = req.systemType;
    sys.connectionConfig = req.connectionConfig;
    sys.status = SystemStatus.configuring;
    sys.createdBy = req.createdBy;
    sys.createdAt = now;
    sys.updatedAt = now;

    repo.save(sys);
    return CommandResult(sys.id, "");
  }

  SourceSystem* getSourceSystem(SourceSystemId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  SourceSystem[] listSourceSystems(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSourceSystem(UpdateSourceSystemRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "System ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Source system not found");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.description.length > 0) updated.description = req.description;
    if (req.connectionConfig.length > 0) updated.connectionConfig = req.connectionConfig;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Activate a source system for provisioning.
  CommandResult activateSystem(SourceSystemId id, TenantId tenantId)
  {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "Source system not found");

    if (sys.connectionConfig.length == 0)
      return CommandResult("", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }

  /// Deactivate a source system.
  CommandResult deactivateSystem(SourceSystemId id, TenantId tenantId)
  {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "Source system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }

  CommandResult deleteSourceSystem(SourceSystemId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Source system not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

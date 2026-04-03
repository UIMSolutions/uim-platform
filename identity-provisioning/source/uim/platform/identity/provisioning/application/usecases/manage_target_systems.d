module application.usecases.manage_target_systems;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.target_system;
import uim.platform.xyz.domain.ports.target_system_repository;
import uim.platform.xyz.application.dto;

class ManageTargetSystemsUseCase
{
  private TargetSystemRepository repo;

  this(TargetSystemRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createTargetSystem(CreateTargetSystemRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Target system with this name already exists");

    auto now = Clock.currStdTime();
    auto sys = TargetSystem();
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

  TargetSystem* getTargetSystem(TargetSystemId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  TargetSystem[] listTargetSystems(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateTargetSystem(UpdateTargetSystemRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "System ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Target system not found");

    auto updated = *existing;
    if (req.name.length > 0) updated.name = req.name;
    if (req.description.length > 0) updated.description = req.description;
    if (req.connectionConfig.length > 0) updated.connectionConfig = req.connectionConfig;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult activateSystem(TargetSystemId id, TenantId tenantId)
  {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "Target system not found");

    if (sys.connectionConfig.length == 0)
      return CommandResult("", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }

  CommandResult deactivateSystem(TargetSystemId id, TenantId tenantId)
  {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "Target system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }

  CommandResult deleteTargetSystem(TargetSystemId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Target system not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

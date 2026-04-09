/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.manage.source_systems;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.source_system;
import uim.platform.identity.provisioning.domain.ports.repositories.source_systems;
import uim.platform.identity.provisioning.application.dto;

class ManageSourceSystemsUseCase : UIMUseCase {
  private SourceSystemRepository repo;

  this(SourceSystemRepository repo) {
    this.repo = repo;
  }

  CommandResult createSourceSystem(CreateSourceSystemRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (existing !is null)
      return CommandResult("", "Source system with this name already exists");

    auto now = Clock.currStdTime();
    auto sys = SourceSystem();
    sys.id = randomUUID();
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

  SourceSystem* getSourceSystem(SourceSystemId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  SourceSystem[] listSourceSystems(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSourceSystem(UpdateSourceSystemRequest req) {
    if (req.id.isEmpty)
      return CommandResult("", "System ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "Source system not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    if (req.connectionConfig.length > 0)
      updated.connectionConfig = req.connectionConfig;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  /// Activate a source system for provisioning.
  CommandResult activateSystem(SourceSystemId id, TenantId tenantId) {
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
  CommandResult deactivateSystem(SourceSystemId id, TenantId tenantId) {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "Source system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }

  CommandResult deleteSourceSystem(SourceSystemId id, TenantId tenantId) {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Source system not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}

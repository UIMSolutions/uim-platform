/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.manage.source_systems;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.source_system;
// import uim.platform.identity.provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity.provisioning.application.dto;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ManageSourceSystemsUseCase { // TODO: UIMUseCase {
  private SourceSystemRepository repo;

  this(SourceSystemRepository repo) {
    this.repo = repo;
  }

  CommandResult createSourceSystem(CreateSourceSystemRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "System name is required");

    auto existing = repo.findByName(req.tenantId, req.name);
    if (!existing.isNull)
      return CommandResult(false, "", "Source system with this name already exists");

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

  SourceSystem* getSourceSystem(SourceSystemId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  SourceSystem[] listSourceSystems(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateSourceSystem(UpdateSourceSystemRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "System ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing.isNull)
      return CommandResult(false, "", "Source system not found");

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
  CommandResult activateSystem(SourceSystemId tenantId, id tenantId) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return CommandResult(false, "", "Source system not found");

    if (sys.connectionConfig.length == 0)
      return CommandResult(false, "", "Connection configuration is required before activation");

    sys.status = SystemStatus.active;
    sys.updatedAt = Clock.currStdTime();
    repo.update(sys);
    return CommandResult(true, id.value, "");
  }

  /// Deactivate a source system.
  CommandResult deactivateSystem(SourceSystemId tenantId, id tenantId) {
    auto sys = repo.findById(tenantId, id);
    if (sys.isNull)
      return CommandResult(false, "", "Source system not found");

    sys.status = SystemStatus.inactive;
    sys.updatedAt = Clock.currStdTime();
    repo.update(sys);
    return CommandResult(true, id.value, "");
  }

  CommandResult deleteSourceSystem(SourceSystemId tenantId, id tenantId) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Source system not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}

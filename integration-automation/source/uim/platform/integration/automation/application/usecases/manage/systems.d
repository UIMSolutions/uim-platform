/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.manage.systems;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.system_connection;

// import uim.platform.integration.automation.domain.ports.repositories.systems;
import uim.platform.integration.automation.domain.ports;
import uim.platform.integration.automation.application.dto;

class ManageSystemsUseCase : UIMUseCase {
  private SystemRepository repo;

  this(SystemRepository repo)
  {
    this.repo = repo;
  }

  CommandResult createSystem(CreateSystemRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult("", "System name is required");
    if (req.host.length == 0)
      return CommandResult("", "Host is required");

    auto now = Clock.currStdTime();

    auto sys = SystemConnection();
    sys.id = randomUUID().toString();
    sys.tenantId = req.tenantId;
    sys.name = req.name;
    sys.description = req.description;
    sys.systemType = req.systemType;
    sys.host = req.host;
    sys.port = req.port > 0 ? req.port : 443;
    sys.client = req.client;
    sys.protocol = req.protocol.length > 0 ? req.protocol : "https";
    sys.status = ConnectionStatus.inactive;
    sys.environment = req.environment;
    sys.region = req.region;
    sys.systemId = req.systemId;
    sys.tenant = req.tenant;
    sys.createdBy = req.createdBy;
    sys.createdAt = now;
    sys.updatedAt = now;

    repo.save(sys);
    return CommandResult(sys.id, "");
  }

  SystemConnection* getSystem(SystemId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  SystemConnection[] listSystems(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  SystemConnection[] listByType(TenantId tenantId, SystemType systemType)
  {
    return repo.findByType(tenantId, systemType);
  }

  CommandResult updateSystem(UpdateSystemRequest req)
  {
    if (req.id.length == 0)
      return CommandResult("", "System ID is required");
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");

    auto existing = repo.findById(req.id, req.tenantId);
    if (existing is null)
      return CommandResult("", "System not found");

    auto updated = *existing;
    if (req.name.length > 0)
      updated.name = req.name;
    if (req.description.length > 0)
      updated.description = req.description;
    updated.systemType = req.systemType;
    if (req.host.length > 0)
      updated.host = req.host;
    if (req.port > 0)
      updated.port = req.port;
    if (req.client.length > 0)
      updated.client = req.client;
    if (req.protocol.length > 0)
      updated.protocol = req.protocol;
    updated.status = req.status;
    if (req.environment.length > 0)
      updated.environment = req.environment;
    if (req.region.length > 0)
      updated.region = req.region;
    if (req.systemId.length > 0)
      updated.systemId = req.systemId;
    if (req.tenant.length > 0)
      updated.tenant = req.tenant;
    updated.updatedAt = Clock.currStdTime();

    repo.update(updated);
    return CommandResult(updated.id, "");
  }

  CommandResult deleteSystem(SystemId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "System not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }

  /// Test a system connection (simulated).
  CommandResult testConnection(SystemId id, TenantId tenantId)
  {
    auto sys = repo.findById(id, tenantId);
    if (sys is null)
      return CommandResult("", "System not found");

    // Simulate connection test — in production, would actually ping the system
    sys.status = ConnectionStatus.active;
    sys.updatedAt = Clock.currStdTime();
    repo.update(*sys);
    return CommandResult(id, "");
  }
}

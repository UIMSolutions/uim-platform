/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.application.usecases.manage.database_connections;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.database_connection;
// import uim.platform.hana.domain.ports.repositories.database_connections;
// import uim.platform.hana.application.dto;

// import uim.platform.service;
// import std.conv : to;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class ManageDatabaseConnectionsUseCase { // TODO: UIMUseCase {
  private DatabaseConnectionRepository repo;

  this(DatabaseConnectionRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateDatabaseConnectionRequest r) {
    if (r.id.isEmpty || r.name.length == 0)
      return CommandResult(false, "", "Connection ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Database connection already exists");

    DatabaseConnection c;
    c.id = r.id;
    c.tenantId = r.tenantId;
    c.instanceId = r.instanceId;
    c.name = r.name;
    c.description = r.description;
    c.status = ConnectionStatus.inactive;
    c.host = r.host;
    c.port = r.port;
    c.database = r.database;
    c.user = r.user;
    c.useTls = r.useTls;
    c.properties = r.properties;

    c.poolConfig.minConnections = r.minConnections;
    c.poolConfig.maxConnections = r.maxConnections;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    c.createdAt = now;
    c.modifiedAt = now;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  DatabaseConnection getById(DatabaseConnectionId id) {
    return repo.findById(id);
  }

  DatabaseConnection[] list(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult update(UpdateDatabaseConnectionRequest r) {
    if (!repo.existsById(r.id))
      return CommandResult(false, "", "Database connection not found");

    auto existing = repo.findById(r.id);
    existing.name = r.name;
    existing.description = r.description;
    existing.host = r.host;
    existing.port = r.port;
    existing.database = r.database;
    existing.user = r.user;

    import core.time : MonoTime;
    existing.modifiedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(DatabaseConnectionId id) {
    if (!repo.existsById(id))
      return CommandResult(false, "", "Database connection not found");

    repo.remove(id);
    return CommandResult(true, id.toString, "");
  }

  size_t count(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}

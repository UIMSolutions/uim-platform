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

import uim.platform.hana;

// mixin(ShowModule!());

@safe:
class ManageDatabaseConnectionsUseCase { // TODO: UIMUseCase {
  private DatabaseConnectionRepository repo;

  this(DatabaseConnectionRepository repo) {
    this.repo = repo;
  }

  CommandResult createDatabaseConnection(CreateDatabaseConnectionRequest r) {
    if (r.isNull || r.name.length == 0)
      return CommandResult(false, "", "Connection ID and name are required");

    if (repo.existsById(r.id))
      return CommandResult(false, "", "Database connection already exists");

    DatabaseConnection c;
    c.initEntity(r.tenantId);
    c.id = r.id;
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

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  DatabaseConnection getDatabaseConnection(TenantId tenantId, DatabaseConnectionId id) {
    return repo.findById(tenantId, id);
  }

  DatabaseConnection[] listDatabaseConnections(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateDatabaseConnection(UpdateDatabaseConnectionRequest r) {
    auto existing = repo.findById(r.tenantId, r.id);
    if (existing.isNull)
      return CommandResult(false, "", "Database connection not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.host = r.host;
    existing.port = r.port;
    existing.database = r.database;
    existing.user = r.user;
    existing.useTls = r.useTls;
    existing.properties = r.properties;

    existing.poolConfig.minConnections = r.minConnections;
    existing.poolConfig.maxConnections = r.maxConnections;

    
    existing.updatedAt = currentTimestamp;

    repo.update(existing);
    return CommandResult(true, existing.id.value, "");
  }

  CommandResult deleteDatabaseConnection(TenantId tenantId, DatabaseConnectionId id) {
    auto connection = repo.findById(tenantId, id);
    if (connection.isNull)
      return CommandResult(false, "", "Database connection not found");

    repo.remove(connection);
    return CommandResult(true, connection.id.value, "");
  }

  size_t countDatabaseConnections(TenantId tenantId) {
    return repo.countByTenant(tenantId);
  }
}

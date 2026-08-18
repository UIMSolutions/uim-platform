/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.connections;

// import uim.platform.datasphere.domain.entities.connection;
// import uim.platform.datasphere.domain.ports.repositories.connections;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ManageConnectionsUseCase {
  protected IConnectionRepository repo;

  this(IConnectionRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createConnection(CreateConnectionRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "Connection name is required");
    if (r.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");

    auto c = Connection(r.tenantId);
    c.spaceId = r.spaceId;
    c.name = r.name;
    c.description = r.description;
    c.host = r.host;
    c.port = r.port;
    c.database = r.database;
    c.user = r.user;
    c.isValid = false;

    repo.save(c);
    return UsecaseResult(true, c.id.value, "");
  }

  Connection getConnection(TenantId tenantId, SpaceId spaceId, ConnectionId id) {
    return repo.findById(tenantId, spaceId, id);
  }

  Connection[] listConnections(TenantId tenantId, SpaceId spaceId) {
    return repo.findBySpace(tenantId, spaceId);
  }

  UsecaseResult updateConnection(UpdateConnectionRequest r) {
    auto connection = repo.findById(r.tenantId, r.spaceId, r.connectionId);
    if (connection.isNull)
      return UsecaseResult(false, "", "Connection not found");

    connection.name = r.name;
    connection.description = r.description;
    connection.host = r.host;
    connection.port = r.port;
    connection.database = r.database;
    connection.user = r.user;
    connection.updatedAt = currentTimestamp;

    repo.update(connection);
    return UsecaseResult(true, connection.id.value, "");
  }

  UsecaseResult deleteConnection(TenantId tenantId, SpaceId spaceId, ConnectionId id) {
    auto connection = repo.findById(tenantId, spaceId, id);
    if (connection.isNull)
      return UsecaseResult(false, "", "Connection not found");

    repo.remove(connection);
    return UsecaseResult(true, connection.id.value, "");
  }
}

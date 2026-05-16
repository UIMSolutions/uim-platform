/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.usecases.manage.connections;
// import uim.platform.ai_launchpad.domain.ports.repositories.connections;
// import uim.platform.ai_launchpad.domain.entities.connection : Connection;
// import uim.platform.ai_launchpad.domain.services.connection_validator;
// import uim.platform.ai_launchpad.domain.types;
// import uim.platform.ai_launchpad.application.dto;
// import std.uuid : randomUUID;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class ManageConnectionsUseCase { // TODO: UIMUseCase {
  private IConnectionRepository repo;
  private ConnectionValidator validator;

  this(IConnectionRepository repo, ConnectionValidator validator) {
    this.repo = repo;
    this.validator = validator;
  }

  CommandResult createConnection(CreateConnectionRequest r) {
    Connection c;
    c.initEntity(r.tenantId);
    
    c.name = r.name;
    c.url = r.url;
    c.authUrl = r.authUrl;
    c.clientId = r.clientId;
    c.clientSecretMasked = r.clientSecret.length > 4 ? "****" ~ r.clientSecret[$ - 4 .. $] : "****";
    c.workspaceId = r.workspaceId;
    c.defaultResourceGroupId = r.defaultResourceGroupId;
    c.description = r.description;
    c.status = ConnectionStatus.pending;

    if (r.type == "ai_core")
      c.type = ConnectionType.ai_core;
    else
      c.type = ConnectionType.custom;

    auto vr = validator.validate(c);
    if (!vr.valid)
      return CommandResult(false, "", vr.error);

    c.status = ConnectionStatus.active;

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  Connection getConnection(ConnectionId id) {
    return repo.findById(tenantId, id);
  }

  Connection[] listConnections(WorkspaceId workspaceId) {
    return repo.findByWorkspace(workspaceId);
  }

  Connection[] listConnections() {
    return repo.findAll();
  }

  CommandResult patchConnection(PatchConnectionRequest r) {
    auto c = repo.findById(r.connectionId);
    if (c.isNull)
      return CommandResult(false, "", "Connection not found");
    if (r.name.length > 0)
      c.name = r.name;
    if (r.description.length > 0)
      c.description = r.description;
    if (r.defaultResourceGroupId.length > 0)
      c.defaultResourceGroupId = r.defaultResourceGroupId;
    c.updatedAt = currentTimestamp();

    repo.save(c);
    return CommandResult(true, c.id.value, "");
  }

  CommandResult deleteConnection(ConnectionId id) {
    auto connection = repo.findById(tenantId, id);
    if (connection.isNull)
      return CommandResult(false, "", "Connection not found");

    repo.remove(connection);
    return CommandResult(true, connection.id.value, "");
  }
}

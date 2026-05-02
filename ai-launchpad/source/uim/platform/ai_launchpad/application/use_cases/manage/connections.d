/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.application.use_cases.manage.connections;

import uim.platform.ai_launchpad.domain.ports.repositories.connections;
import uim.platform.ai_launchpad.domain.entities.connection : Connection;
import uim.platform.ai_launchpad.domain.services.connection_validator;
import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class ManageConnectionsUseCase { // TODO: UIMUseCase {
  private IConnectionRepository repo;
  private ConnectionValidator validator;

  this(IConnectionRepository repo, ConnectionValidator validator) {
    this.repo = repo;
    this.validator = validator;
  }

  CommandResult create(CreateConnectionRequest r) {
    Connection c;
    c.id = randomUUID();
    c.name = r.name;
    c.url = r.url;
    c.authUrl = r.authUrl;
    c.clientId = r.clientId;
    c.clientSecretMasked = r.clientSecret.length > 4 ? "****" ~ r.clientSecret[$ - 4 .. $] : "****";
    c.workspaceId = r.workspaceId;
    c.defaultResourceGroupId = r.defaultResourceGroupId;
    c.description = r.description;
    c.status = ConnectionStatus.pending;

    if (r.type == "ai_core") c.type = ConnectionType.ai_core;
    else c.type = ConnectionType.custom;

    auto vr = validator.validate(c);
    if (!vr.valid) return CommandResult(false, "", vr.error);

    c.status = ConnectionStatus.active;
    c.createdAt = "now";
    c.updatedAt = "now";
    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Connection getById(ConnectionId id) {
    return repo.findById(id);
  }

  Connection[] listByWorkspace(WorkspaceId workspaceId) {
    return repo.findByWorkspace(workspaceId);
  }

  Connection[] listAll() {
    return repo.findAll();
  }

  CommandResult patch(PatchConnectionRequest r) {
    auto c = repo.findById(r.connectionId);
    if (c.isNull) return CommandResult(false, "", "Connection not found");
    if (r.name.length > 0) c.name = r.name;
    if (r.description.length > 0) c.description = r.description;
    if (r.defaultResourceGroupId.length > 0) c.defaultResourceGroupId = r.defaultResourceGroupId;
    c.updatedAt = "now";
    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  CommandResult remove(ConnectionId id) {
    auto c = repo.findById(id);
    if (c.isNull) return CommandResult(false, "", "Connection not found");
    repo.removeById(id);
    return CommandResult(true, id.value, "");
  }
}

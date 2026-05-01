/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.connections;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.connection;
import uim.platform.datasphere.domain.ports.repositories.connections;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageConnectionsUseCase { // TODO: UIMUseCase {
  private ConnectionRepository repo;

  this(ConnectionRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateConnectionRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Connection name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID();

    Connection c;
    c.id = randomUUID();
    c.tenantId = r.tenantId;
    c.spaceId = r.spaceId;
    c.name = r.name;
    c.description = r.description;
    c.host = r.host;
    c.port = r.port;
    c.database = r.database;
    c.user = r.user;
    c.isValid = false;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    c.createdAt = now;
    c.updatedAt = now;

    repo.save(c);
    return CommandResult(true, c.id, "");
  }

  Connection getById(ConnectionId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  Connection[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult update(UpdateConnectionRequest r) {
    auto existing = repo.findById(r.connectionId, r.spaceId);
    if (existing.isNull)
      return CommandResult(false, "", "Connection not found");

    existing.name = r.name;
    existing.description = r.description;
    existing.host = r.host;
    existing.port = r.port;
    existing.database = r.database;
    existing.user = r.user;

    import core.time : MonoTime;
    existing.updatedAt = MonoTime.currTime.ticks;

    repo.update(existing);
    return CommandResult(true, existing.id, "");
  }

  CommandResult remove(ConnectionId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.isNull)
      return CommandResult(false, "", "Connection not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id.toString, "");
  }
}

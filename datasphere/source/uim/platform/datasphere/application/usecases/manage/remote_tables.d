/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.remote_tables;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.remote_table;
import uim.platform.datasphere.domain.ports.repositories.remote_tables;
import uim.platform.datasphere.application.dto;

import uim.platform.service;
import std.conv : to;

class ManageRemoteTablesUseCase : UIMUseCase {
  private RemoteTableRepository repo;

  this(RemoteTableRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateRemoteTableRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Remote table name is required");
    if (r.spaceid.isEmpty)
      return CommandResult(false, "", "Space ID is required");
    if (r.connectionid.isEmpty)
      return CommandResult(false, "", "Connection ID is required");

    import std.uuid : randomUUID;
    auto id = randomUUID().to!string;

    RemoteTable rt;
    rt.id = id;
    rt.tenantId = r.tenantId;
    rt.spaceId = r.spaceId;
    rt.connectionId = r.connectionId;
    rt.name = r.name;
    rt.description = r.description;
    rt.remoteSchema = r.remoteSchema;
    rt.remoteObjectName = r.remoteObjectName;
    rt.replicationMode = ReplicationMode.none;

    import core.time : MonoTime;
    auto now = MonoTime.currTime.ticks;
    rt.createdAt = now;
    rt.modifiedAt = now;

    repo.save(rt);
    return CommandResult(true, rt.id, "");
  }

  RemoteTable get_(RemoteTableId id, SpaceId spaceId) {
    return repo.findById(id, spaceId);
  }

  RemoteTable[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  CommandResult remove(RemoteTableId id, SpaceId spaceId) {
    auto existing = repo.findById(id, spaceId);
    if (existing.id.isEmpty)
      return CommandResult(false, "", "Remote table not found");

    repo.remove(id, spaceId);
    return CommandResult(true, id, "");
  }
}

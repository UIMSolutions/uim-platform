/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.remote_tables;

// import uim.platform.datasphere.domain.entities.remote_table;
// import uim.platform.datasphere.domain.ports.repositories.remote_tables;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class ManageRemoteTablesUseCase { // TODO: UIMUseCase {
  private RemoteTableRepository tables;

  this(RemoteTableRepository tables) {
    this.tables = tables;
  }

  CommandResult createRemoteTable(CreateRemoteTableRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "Remote table name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");
    if (r.connectionId.isEmpty)
      return CommandResult(false, "", "Connection ID is required");

    import std.uuid : randomUUID;

    RemoteTable rt;
    rt.initEntity(r.tenantId) ;

    rt.spaceId = r.spaceId;
    rt.connectionId = r.connectionId;
    rt.name = r.name;
    rt.description = r.description;
    rt.remoteSchema = r.remoteSchema;
    rt.remoteObjectName = r.remoteObjectName;
    rt.replicationMode = ReplicationMode.none;

    tables.save(rt);
    return CommandResult(true, rt.id.value, "");
  }

  RemoteTable getRemoteTable(SpaceId spaceId, RemoteTableId id) {
    return tables.findById(spaceId, id);
  }

  RemoteTable[] listRemoteTables(SpaceId spaceId) {
    return tables.findBySpace(spaceId);
  }

  CommandResult deleteRemoteTable(SpaceId spaceId, RemoteTableId id) {
    auto table = tables.findById(spaceId, id);
    if (table.isNull)
      return CommandResult(false, "", "Remote table not found");

    tables.remove(table);
    return CommandResult(true, table.id.value, "");
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Data integration: connections and remote tables.
///
///   * changing host, port, database, user, password or type of a connection
///     resets its status to "untested"
///   * a connection cannot be deleted while remote tables use it
///   * a remote table belongs to a connection of its own space; its name is
///     unique among the objects of the space
///   * a remote table cannot be deleted while views, data flows or tasks use it
module uim.platform.datasphere.application.usecases.integration;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class ManageConnectionsUseCase : ResourceInteractor!(Connection, ConnectionId, ConnectionInput), IManageConnections {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(Connection, ConnectionId) store() {
    return repos.connections;
  }

  protected override string what() {
    return "Connection";
  }

  protected override string eventPrefix() {
    return "connection";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId"];
  }

  protected override ConnectionInput toInput(const Connection e) {
    ConnectionInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.description = e.description;
    i.connectionType = cast(string) e.connectionType;
    i.host = e.host;
    i.port = e.port;
    i.database = e.database;
    i.user = e.user;
    i.password = e.password;
    i.properties = e.properties.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref Connection e, ConnectionInput i, bool creating) {
    if (creating)
      activeSpace(t, i.spaceId, "Creating a connection");
    auto before = e.endpoint ~ "|" ~ e.user ~ "|" ~ e.password ~ "|" ~ cast(string) e.connectionType;
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.connectionType = parseDomainEnum!ConnectionType(i.connectionType, "connection type");
    e.host = i.host.strip;
    e.port = i.port;
    e.database = i.database.strip;
    e.user = i.user.strip;
    if (i.password.length) // "" keeps the stored password
      e.password = i.password;
    e.properties = i.properties.map!(p => p.strip).filter!(p => p.length > 0).array;
    if (!creating && before != e.endpoint ~ "|" ~ e.user ~ "|" ~ e.password ~ "|" ~ cast(string) e.connectionType)
      e.invalidate();
  }

  protected override void beforeRemove(TenantId t, const Connection e, UserId actor) {
    requireUnused("Connection '" ~ e.id.value ~ "'", repos.remoteTables.countByReference(t, "connectionId", e.id.value),
      "remote tables");
  }

  Connection validateConnection(TenantId t, ConnectionId id, UserId actor) {
    auto c = get(t, id);
    return runner.checkConnection(c, actor);
  }
}

class ManageRemoteTablesUseCase : ResourceInteractor!(RemoteTable, RemoteTableId, RemoteTableInput), IManageRemoteTables {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(RemoteTable, RemoteTableId) store() {
    return repos.remoteTables;
  }

  protected override string what() {
    return "Remote table";
  }

  protected override string eventPrefix() {
    return "remoteTable";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId", "connectionId", "name"];
  }

  protected override RemoteTableInput toInput(const RemoteTable e) {
    RemoteTableInput i;
    i.spaceId = e.spaceId.value;
    i.connectionId = e.connectionId.value;
    i.name = e.name;
    i.businessName = e.businessName;
    i.description = e.description;
    i.remoteSchema = e.remoteSchema;
    i.remoteObject = e.remoteObject;
    i.replicationMode = cast(string) e.replicationMode;
    i.columns = e.columns.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref RemoteTable e, RemoteTableInput i, bool creating) {
    if (creating) {
      auto space = activeSpace(t, i.spaceId, "Creating a remote table");
      auto conn = required(repos.connections.findById(t, ConnectionId(i.connectionId.strip)),
        "Connection '" ~ i.connectionId.strip ~ "'");
      if (conn.spaceId != space.id)
        throw DspException.ruleViolation("Connection '" ~ conn.id.value ~ "' belongs to space '" ~ conn.spaceId.value ~ "'");
      requireUniqueName(t, space.id, i.name.strip);
    }
    e.spaceId = SpaceId(i.spaceId.strip);
    e.connectionId = ConnectionId(i.connectionId.strip);
    e.name = i.name.strip;
    e.businessName = i.businessName.strip.length ? i.businessName.strip : e.name;
    e.description = i.description.strip;
    e.remoteSchema = i.remoteSchema.strip;
    e.remoteObject = i.remoteObject.strip;
    auto mode = parseDomainEnum!ReplicationMode(i.replicationMode, "replication mode");
    if (!creating && mode == ReplicationMode.remote && e.replicationMode != ReplicationMode.remote)
      e.dropReplica(); // back to federation
    if (mode == ReplicationMode.realtime) {
      auto conn = repos.connections.findById(t, e.connectionId);
      if (!conn.isNull && !conn.connectionType.supportsRealtime)
        throw DspException.ruleViolation("Connections of type '" ~ cast(string) conn.connectionType
            ~ "' do not support real-time replication");
    }
    e.replicationMode = mode;
    e.columns = i.columns.map!(c => c.strip).filter!(c => c.length > 0).array;
  }

  /// Switching back to "remote" drops the replica: refresh the used disk.
  override RemoteTable update(UpdateCommand!RemoteTableInput c) {
    auto e = super.update(c);
    runner.refreshUsage(c.tenantId, e.spaceId);
    return e;
  }

  protected override void beforeRemove(TenantId t, const RemoteTable e, UserId actor) {
    auto s = e.spaceId.value;
    auto views = repos.views.findByReference(t, "spaceId", s).count!(v => v.sourceObjects.containsName(e.name));
    requireUnused("Remote table '" ~ e.name ~ "'", views, "views");
    auto flows = repos.dataFlows.findByReference(t, "spaceId", s).count!(f => f.sourceObjects.containsName(e.name));
    requireUnused("Remote table '" ~ e.name ~ "'", flows, "data flows");
    auto tasks = repos.tasks.findByReference(t, "targetObjectId", e.id.value).count!(x => x.taskType == TaskType.replication);
    requireUnused("Remote table '" ~ e.name ~ "'", tasks, "tasks");
  }

  override void remove(TenantId t, RemoteTableId id, UserId actor) {
    auto space = get(t, id).spaceId;
    super.remove(t, id, actor);
    runner.refreshUsage(t, space);
  }

  TaskRun replicate(TenantId t, RemoteTableId id, UserId actor) {
    auto table = get(t, id);
    RunContext rc;
    rc.actor = actor;
    return runner.replicate(t, table.spaceId, id, rc);
  }

  RemoteTable dropReplica(TenantId t, RemoteTableId id, UserId actor) {
    auto table = get(t, id);
    table.dropReplica();
    table.replicationMode = ReplicationMode.remote;
    table.lastMessage = "replica removed";
    stampUpdated(table, actor, now);
    repos.remoteTables.save(table);
    runner.refreshUsage(t, table.spaceId);
    emit("remoteTable.replicaDropped", t, id.value);
    return table;
  }
}

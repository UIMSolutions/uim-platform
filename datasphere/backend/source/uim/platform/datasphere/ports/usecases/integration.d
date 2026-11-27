/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of data integration: connections and remote tables.
module uim.platform.datasphere.ports.usecases.integration;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IManageConnections : IManageResource!(Connection, ConnectionId, ConnectionInput) {
  /// Check reachability and credentials; stores the result on the connection.
  Connection validateConnection(TenantId t, ConnectionId id, UserId actor);
}

interface IManageRemoteTables : IManageResource!(RemoteTable, RemoteTableId, RemoteTableInput) {
  /// Load a snapshot now (logged as a replication run).
  TaskRun replicate(TenantId t, RemoteTableId id, UserId actor);
  /// Back to federated access: the replica is removed.
  RemoteTable dropReplica(TenantId t, RemoteTableId id, UserId actor);
}

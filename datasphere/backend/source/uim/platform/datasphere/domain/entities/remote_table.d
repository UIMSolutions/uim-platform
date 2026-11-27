/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A remote table: a remote object (table, CDS view, topic, file) of a
/// connection, accessed federated or replicated into the space.
module uim.platform.datasphere.domain.entities.remote_table;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct RemoteTable {
  mixin TenantEntity!RemoteTableId;

  SpaceId spaceId;
  ConnectionId connectionId;
  string name; /// technical name in the space
  string businessName;
  string description;
  string remoteSchema;
  string remoteObject; /// table / CDS view / entity set / topic / file
  ReplicationMode replicationMode = ReplicationMode.remote;
  ReplicationStatus replicationStatus = ReplicationStatus.notReplicated;
  string[] columns; /// "NAME:TYPE(len) [key]"
  long rowCount; /// rows of the last snapshot
  long sizeBytes; /// disk used by the replica
  long lastReplicatedAt;
  string lastMessage;

  /// True if the data lies in the space (and counts against its quota).
  bool holdsData() const {
    return replicationStatus == ReplicationStatus.replicated || replicationStatus == ReplicationStatus.active;
  }

  /// "schema.object"
  string remotePath() const {
    return remoteSchema.length ? remoteSchema ~ "." ~ remoteObject : remoteObject;
  }

  /// Switch back to federation: the replica is dropped.
  void dropReplica() {
    replicationStatus = ReplicationStatus.notReplicated;
    rowCount = 0;
    sizeBytes = 0;
  }

  void validate() const {
    requireId(id.value, "Remote table ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the remote table is required");
    if (connectionId.isNull)
      throw DspException.invalid("The connection of the remote table is required");
    requireId(name, "Technical name");
    requireMaxLength(businessName, 200, "Business name");
    requireMaxLength(description, 2000, "Description");
    requireText(remoteObject, "Remote object");
    requireMaxLength(remoteObject, 500, "Remote object");
    requireMaxLength(remoteSchema, 200, "Remote schema");
    parseColumns(columns);
  }
}

///
unittest {
  RemoteTable t;
  t.id = RemoteTableId("orders");
  t.spaceId = SpaceId("SALES");
  t.connectionId = ConnectionId("S4");
  t.name = "S4_SALES_ORDERS";
  t.remoteSchema = "SAP";
  t.remoteObject = "I_SALESORDER";
  t.columns = ["SALESORDER:NVARCHAR(10) key", "NETAMOUNT:DECIMAL(15,2)"];
  t.validate();
  assert(t.remotePath == "SAP.I_SALESORDER" && !t.holdsData);
  t.replicationStatus = ReplicationStatus.replicated;
  t.sizeBytes = 10;
  assert(t.holdsData);
  t.dropReplica();
  assert(!t.holdsData && t.sizeBytes == 0);
  t.columns = ["broken"];
  assert(failsWith(DspErrorKind.invalid, () { t.validate(); }));
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// A deployment target or source in the transport landscape
/// (Cloud Foundry space, ABAP system, Neo subaccount or Kyma cluster).
/// Every node owns an import queue (see ImportQueueEntry).
struct TransportNode {
  mixin TenantEntity!TransportNodeId;

  string name;
  string description;
  NodeType nodeType = NodeType.cloudFoundry;
  NodeStatus status = NodeStatus.enabled;
  string environment;
  string region;
  string globalAccount;
  SubaccountId subaccountId;
  SpaceId spaceId;
  /// Credentials / destination name used by the deployment gateway. Never serialized to clients.
  string serviceKey;
  /// After a successful import, forward the request to the follow-on nodes.
  bool isForwardEnabled = true;
  /// Let the auto-import worker import this node's queue periodically.
  bool autoImport = false;
  string autoImportSchedule;
  long lastCheckedAt;
  string connectionStatus;

  bool isEnabled() const {
    return status == NodeStatus.enabled;
  }

  void enable(UserId by = UserId.init) {
    status = NodeStatus.enabled;
    touch(by);
  }

  void disable(UserId by = UserId.init) {
    status = NodeStatus.disabled;
    touch(by);
  }

  void touch(UserId by) {
    updatedAt = Clock.currStdTime();
    if (!by.isEmpty)
      updatedBy = by;
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("nodeType", enumName(nodeType))
      .set("status", enumName(status))
      .set("environment", environment)
      .set("region", region)
      .set("globalAccount", globalAccount)
      .set("subaccountId", subaccountId.value)
      .set("spaceId", spaceId.value)
      .set("isForwardEnabled", isForwardEnabled)
      .set("autoImport", autoImport)
      .set("autoImportSchedule", autoImportSchedule)
      .set("lastCheckedAt", lastCheckedAt)
      .set("connectionStatus", connectionStatus);
  }
}

///
unittest {
  mixin(ShowTest!("TransportNode"));

  auto n = TransportNode(TenantId("t1"));
  n.name = "DEV";
  n.serviceKey = "secret";
  assert(n.isEnabled);
  n.disable();
  assert(!n.isEnabled);
  assert("serviceKey" !in n.toJson);
  assert(n.toJson["status"].get!string == "disabled");
}

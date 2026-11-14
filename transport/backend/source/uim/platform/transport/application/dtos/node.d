/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Input of "create transport node".
struct CreateNodeInput {
  TenantId tenantId;
  string id; /// optional — generated if empty
  string name;
  string description;
  string nodeType; /// NodeType name, default cloudFoundry
  string environment;
  string region;
  string globalAccount;
  string subaccountId;
  string spaceId;
  string serviceKey;
  bool isForwardEnabled = true;
  bool autoImport;
  string autoImportSchedule;
  UserId createdBy;
}

/// Input of "update transport node": the complete set of mutable fields
/// (adapters with PATCH semantics prefill it with UpdateNodeInput.from(current)).
struct UpdateNodeInput {
  TenantId tenantId;
  TransportNodeId nodeId;
  string name;
  string description;
  string nodeType;
  string environment;
  string region;
  string globalAccount;
  string subaccountId;
  string spaceId;
  string serviceKey; /// "" keeps the stored key
  bool isForwardEnabled = true;
  bool autoImport;
  string autoImportSchedule;
  UserId updatedBy;

  static UpdateNodeInput from(const TransportNode n) {
    UpdateNodeInput u;
    u.tenantId = n.tenantId;
    u.nodeId = n.id;
    u.name = n.name;
    u.description = n.description;
    u.nodeType = enumName(n.nodeType);
    u.environment = n.environment;
    u.region = n.region;
    u.globalAccount = n.globalAccount;
    u.subaccountId = n.subaccountId.value;
    u.spaceId = n.spaceId.value;
    u.isForwardEnabled = n.isForwardEnabled;
    u.autoImport = n.autoImport;
    u.autoImportSchedule = n.autoImportSchedule;
    return u;
  }
}

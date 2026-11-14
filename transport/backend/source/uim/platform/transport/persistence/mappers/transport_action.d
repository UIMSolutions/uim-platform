/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.mappers.transport_action;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportActionMapper {
  static Json toRecord(const TransportAction e) {
    auto r = baseRecord(e);
    r["actionType"] = enumName(e.actionType);
    r["actionStatus"] = enumName(e.actionStatus);
    r["nodeId"] = e.nodeId.value;
    r["requestId"] = e.requestId.value;
    r["routeId"] = e.routeId.value;
    r["performedBy"] = e.performedBy;
    r["performedAt"] = e.performedAt;
    r["completedAt"] = e.completedAt;
    r["description"] = e.description;
    r["errorMessage"] = e.errorMessage;
    r["logDetails"] = e.logDetails;
    return r;
  }

  static TransportAction fromRecord(Json r) {
    TransportAction e;
    readBase(e, r);
    e.actionType = fieldEnum!ActionType(r, "actionType", ActionType.export_);
    e.actionStatus = fieldEnum!ActionStatus(r, "actionStatus", ActionStatus.initial);
    e.nodeId = TransportNodeId(fieldString(r, "nodeId"));
    e.requestId = TransportRequestId(fieldString(r, "requestId"));
    e.routeId = TransportRouteId(fieldString(r, "routeId"));
    e.performedBy = fieldString(r, "performedBy");
    e.performedAt = fieldLong(r, "performedAt");
    e.completedAt = fieldLong(r, "completedAt");
    e.description = fieldString(r, "description");
    e.errorMessage = fieldString(r, "errorMessage");
    e.logDetails = fieldString(r, "logDetails");
    return e;
  }
}

///
unittest {
  mixin(ShowTest!("Transport mappers"));

  auto a = TransportAction(TenantId("t"));
  a.actionType = ActionType.import_;
  a.performedBy = "jane";
  auto back = TransportActionMapper.fromRecord(TransportActionMapper.toRecord(a));
  assert(back.id == a.id && back.actionType == ActionType.import_ && back.performedBy == "jane");
  assert(TransportActionMapper.toRecord(a)["actionType"].get!string == "import");

  auto n = TransportNode(TenantId("t"));
  n.name = "DEV";
  n.serviceKey = "k";
  auto nb = TransportNodeMapper.fromRecord(TransportNodeMapper.toRecord(n));
  assert(nb.name == "DEV" && nb.serviceKey == "k" && nb.isForwardEnabled);
}

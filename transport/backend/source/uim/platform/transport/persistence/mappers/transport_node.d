/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.mappers.transport_node;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportNodeMapper {
  static Json toRecord(const TransportNode e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["nodeType"] = enumName(e.nodeType);
    r["status"] = enumName(e.status);
    r["environment"] = e.environment;
    r["region"] = e.region;
    r["globalAccount"] = e.globalAccount;
    r["subaccountId"] = e.subaccountId.value;
    r["spaceId"] = e.spaceId.value;
    r["serviceKey"] = e.serviceKey;
    r["isForwardEnabled"] = e.isForwardEnabled;
    r["autoImport"] = e.autoImport;
    r["autoImportSchedule"] = e.autoImportSchedule;
    r["lastCheckedAt"] = e.lastCheckedAt;
    r["connectionStatus"] = e.connectionStatus;
    return r;
  }

  static TransportNode fromRecord(Json r) {
    TransportNode e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.nodeType = fieldEnum!NodeType(r, "nodeType", NodeType.cloudFoundry);
    e.status = fieldEnum!NodeStatus(r, "status", NodeStatus.enabled);
    e.environment = fieldString(r, "environment");
    e.region = fieldString(r, "region");
    e.globalAccount = fieldString(r, "globalAccount");
    e.subaccountId = SubaccountId(fieldString(r, "subaccountId"));
    e.spaceId = SpaceId(fieldString(r, "spaceId"));
    e.serviceKey = fieldString(r, "serviceKey");
    e.isForwardEnabled = fieldBool(r, "isForwardEnabled", true);
    e.autoImport = fieldBool(r, "autoImport");
    e.autoImportSchedule = fieldString(r, "autoImportSchedule");
    e.lastCheckedAt = fieldLong(r, "lastCheckedAt");
    e.connectionStatus = fieldString(r, "connectionStatus");
    return e;
  }
}

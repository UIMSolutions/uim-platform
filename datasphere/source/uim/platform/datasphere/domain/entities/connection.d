/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.connection;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct ConnectionProperty {
  string key;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("key", key)
      .set("value", value);
  }
}

struct Connection {
  mixin TenantEntity!ConnectionId;

  SpaceId spaceId;
  string name;
  string description;
  ConnectionType type;
  string host;
  int port;
  string database;
  string user;
  ConnectionProperty[] properties;
  bool isValid;
  string statusMessage;
  
  Json toJson() const {
    auto propsJson = Json.emptyArray;
    foreach (prop; properties) {
      propsJson ~= prop.toJson();
    }

    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("type", type.to!string())
      .set("host", host)
      .set("port", port)
      .set("database", database)
      .set("user", user)
      .set("properties", propsJson)
      .set("isValid", isValid)
      .set("statusMessage", statusMessage);
  }
}

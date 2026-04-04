/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.connection;

import uim.platform.datasphere.domain.types;

struct ConnectionProperty {
  string key;
  string value;
}

struct Connection {
  ConnectionId id;
  TenantId tenantId;
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
  long createdAt;
  long modifiedAt;
}

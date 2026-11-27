/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A connection of a space to a source system (SAP HANA, S/4HANA, BW,
/// OData, SQL, Kafka, files …). The password is write-only: it is stored
/// for the processing engine and never returned by any API.
module uim.platform.datasphere.domain.entities.connection;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct Connection {
  mixin TenantEntity!ConnectionId;

  SpaceId spaceId;
  string name;
  string description;
  ConnectionType connectionType = ConnectionType.hana;
  string host;
  int port;
  string database; /// database / schema / service path
  string user;
  string password; /// write-only secret
  string[] properties; /// "key=value" (e.g. "encrypt=true")
  ConnectionStatus status = ConnectionStatus.untested;
  string statusMessage;
  long lastValidatedAt;

  bool isValid() const {
    return status == ConnectionStatus.valid;
  }

  bool hasCredentials() const {
    return user.length > 0 && password.length > 0;
  }

  /// "host:port/database" (for lists and logs; never the credentials).
  string endpoint() const {
    if (host.length == 0)
      return database;
    return host ~ (port > 0 ? ":" ~ port.to!string : "") ~ (database.length ? "/" ~ database : "");
  }

  /// Technical attributes changed: the connection must be validated again.
  void invalidate() {
    status = ConnectionStatus.untested;
    statusMessage = "";
  }

  void validate() const {
    requireId(id.value, "Connection ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the connection is required");
    requireText(name, "Connection name");
    requireMaxLength(name, 200, "Connection name");
    requireMaxLength(description, 2000, "Description");
    if (connectionType.needsEndpoint) {
      requireText(host, "Host");
      requireRange(port, 1, 65_535, "Port");
    } else if (port != 0)
      requireRange(port, 1, 65_535, "Port");
    if (host.canFind(' ') || host.canFind('/'))
      throw DspException.invalid("Host '" ~ host ~ "' must be a host name or address (no scheme or path)");
    requireMaxLength(host, 253, "Host");
    requireMaxLength(database, 500, "Database");
    requireMaxLength(user, 200, "User");
    requireMaxLength(password, 1000, "Password");
    foreach (p; properties)
      if (!p.canFind('=') || p.startsWith("="))
        throw DspException.invalid("Connection property '" ~ p ~ "' must have the form key=value");
  }
}

///
unittest {
  Connection c;
  c.id = ConnectionId("S4");
  c.spaceId = SpaceId("SALES");
  c.name = "S/4HANA Cloud";
  c.connectionType = ConnectionType.s4hana;
  assert(failsWith(DspErrorKind.invalid, () { c.validate(); }), "s4hana needs host and port");
  c.host = "my-s4.s4hana.cloud.sap";
  c.port = 443;
  c.validate();
  assert(c.endpoint == "my-s4.s4hana.cloud.sap:443" && !c.isValid && !c.hasCredentials);
  c.properties = ["encrypt"];
  assert(failsWith(DspErrorKind.invalid, () { c.validate(); }));
  c.properties = ["encrypt=true"];
  c.connectionType = ConnectionType.file;
  c.host = "";
  c.port = 0;
  c.database = "s3://bucket/sales";
  c.validate();
  assert(c.endpoint == "s3://bucket/sales");
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.entities.system_connection;

// import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// A system in the customer landscape — represents an endpoint
/// that participates in integration scenarios.
struct SystemConnection {  
  mixin(TenantEntity!SystemConnectionId);

  string name; // e.g. "Production S/4HANA"
  string description;
  SystemType systemType;
  string host;
  ushort port;
  string client; // SAP client number
  string protocol = "https";
  ConnectionStatus status = ConnectionStatus.inactive;
  string environment; // e.g. "production", "staging", "dev"
  string region; // e.g. "eu10", "us20"
  string systemId; // SAP SID
  string tenant; // subaccount / tenant identifier

  Json toJson() const {
      return entityToJson()
          .set("name", name)
          .set("description", description)
          .set("systemType", systemType.to!string)
          .set("host", host)
          .set("port", port)
          .set("client", client)
          .set("protocol", protocol)
          .set("status", status.to!string)
          .set("environment", environment)
          .set("region", region)
          .set("systemId", systemId)
          .set("tenant", tenant);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the connectivity service: which kinds exist, how
/// they are named per protocol, their table columns, actions and secrets.
module uim.platform.connectivity.presentation.resources.registry;

import uim.platform.connectivity;
import uim.platform.connectivity.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference a Cloud Connector (accept an id or a unique connector name).
enum string[] connectorReferenceFields = ["connectorId"];

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  ConnectivityPorts ports;

  this(ConnectivityPorts ports) {
    this.ports = ports;
    auto p = ports;

    _adapters ~= new ResourceAdapter!(Destination, DestinationId, CreateDestinationRequest, UpdateDestinationRequest)(
      p.destinations, "destinations", "Destinations", "Destination", "Destinations", "")
      .column("Name", "name").column("Type", "destinationType").column("Proxy", "proxyType")
      .column("Authentication", "authenticationType").column("URL", "url").column("Status", "status")
      .column("Latency (ms)", "latencyMs").column("ID", "id")
      .secret("password").secret("clientSecret").secret("tokenServicePassword")
      .action("check", "Check Connection", (who, id, _) => p.destinations.check(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(CloudConnector, ConnectorId, RegisterConnectorRequest, UpdateConnectorRequest)(
      p.connectors, "connectors", "CloudConnectors", "CloudConnector", "Cloud Connectors", "")
      .column("Name", "name").column("Location", "locationId").column("Subaccount", "subaccountId")
      .column("Host", "host").column("Version", "connectorVersion").column("Status", "status")
      .column("Last Heartbeat", "lastHeartbeatAt").column("ID", "id")
      .action("heartbeat", "Heartbeat", (who, id, params) => p.connectors.heartbeat(who.tenantId, id,
          fieldString(params, "connectorVersion"), who.userId), ["connectorVersion"])
      .action("disconnect", "Disconnect", (who, id, _) => p.connectors.disconnect(who.tenantId, id, who.userId))
      .action("reconnect", "Reconnect", (who, id, _) => p.connectors.reconnect(who.tenantId, id, who.userId))
      .action("start-maintenance", "Start Maintenance", (who, id, _) => p.connectors.startMaintenance(who.tenantId,
          id, who.userId));

    _adapters ~= new ResourceAdapter!(ServiceChannel, ChannelId, CreateChannelRequest, UpdateChannelRequest)(
      p.channels, "channels", "ServiceChannels", "ServiceChannel", "Service Channels", "connectorId")
      .column("Name", "name").column("Connector", "connectorName").column("Type", "channelType")
      .column("Virtual Host", "virtualHost").column("Virtual Port", "virtualPort")
      .column("Back-end Host", "backendHost").column("Back-end Port", "backendPort").column("Status", "status")
      .column("ID", "id")
      .action("open", "Open", (who, id, _) => p.channels.open(who.tenantId, id, who.userId))
      .action("close", "Close", (who, id, _) => p.channels.close(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(AccessRule, AccessRuleId, CreateAccessRuleRequest, UpdateAccessRuleRequest)(
      p.accessRules, "access-rules", "AccessRules", "AccessRule", "Access Rules", "connectorId")
      .column("Name", "name").column("Connector", "connectorName").column("Protocol", "protocol")
      .column("Virtual Host", "virtualHost").column("Port", "virtualPort").column("Path", "urlPathPrefix")
      .column("Sub-Paths", "includeSubPaths").column("Policy", "policy").column("Enabled", "enabled")
      .column("ID", "id")
      .action("enable", "Enable", (who, id, _) => p.accessRules.enable(who.tenantId, id, who.userId))
      .action("disable", "Disable", (who, id, _) => p.accessRules.disable(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(Certificate, CertificateId, CreateCertificateRequest, UpdateCertificateRequest)(
      p.certificates, "certificates", "Certificates", "Certificate", "Certificates", "")
      .column("Name", "name").column("Type", "certificateType").column("Usage", "usage")
      .column("Subject", "subjectDN").column("Expires", "expiresAt").column("Status", "status").column("ID", "id")
      .action("revoke", "Revoke", (who, id, _) => p.certificates.revoke(who.tenantId, id, who.userId))
      .action("renew", "Renew", (who, id, params) => p.certificates.renew(who.tenantId, id,
          cast(int) fieldLong(params, "validDays", 365), who.userId), ["validDays"]);

    _adapters ~= new ResourceAdapter!(ConnectivityLogEntry, LogEntryId, CreateLogEntryRequest, UpdateLogEntryRequest)(
      p.logs, "logs", "ConnectivityLogs", "ConnectivityLog", "Event Log", "")
      .column("Occurred", "occurredAt").column("Severity", "severity").column("Event", "eventType")
      .column("Source", "sourceName").column("Message", "message").column("ID", "id")
      .appendOnly();
  }

  IResourceAdapter[] adapters() {
    return _adapters;
  }

  /// Adapter by REST path / CLI command (null if unknown).
  IResourceAdapter byPath(string path) {
    foreach (a; _adapters)
      if (a.path == path)
        return a;
    return null;
  }

  /// Adapter by OData entity set (null if unknown).
  IResourceAdapter bySet(string setName) {
    foreach (a; _adapters)
      if (a.setName == setName)
        return a;
    return null;
  }

  /// Adapter owning an OData action name (null if unknown); `action` receives the action.
  IResourceAdapter byODataAction(string odataName, out ResourceAction action) {
    foreach (a; _adapters)
      foreach (act; a.actions)
        if (act.odataName == odataName) {
          action = act;
          return a;
        }
    return null;
  }

  /// An id, or the id of the unique resource of `adapter` with that name.
  string resolve(IResourceAdapter adapter, TenantId tenantId, string idOrName) {
    if (adapter.get(tenantId, idOrName).type != Json.Type.null_)
      return idOrName;
    auto matches = adapter.list(tenantId, ["name": idOrName]);
    if (matches.length == 1)
      return matches[0]["id"].get!string;
    if (matches.length > 1)
      throw new ResourceError(400, "Ambiguous", "'" ~ idOrName ~ "' matches " ~ matches.length.to!string
          ~ " " ~ adapter.path ~ " — use the id");
    throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ idOrName ~ "' not found");
  }

  /// A copy of `body` with every connector reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = connectorReferenceFields.canFind(k) && jsonText(v).length > 0
        ? Json(resolve(byPath("connectors"), tenantId, jsonText(v))) : v;
    return result;
  }

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Run the health check and return the report payload.
  Json healthCheck(TenantId tenantId) {
    return encode(ports.healthCheck.run(tenantId), true);
  }

  /// Access check payload (`connector` is an id or a name).
  Json checkAccess(RequestIdentity who, string connector, string url) {
    if (connector.strip.length == 0 || url.strip.length == 0)
      throw new ResourceError(400, "MissingParameter", "CheckAccess requires 'connector' and 'url'");
    AccessCheckRequest r;
    r.tenantId = who.tenantId;
    r.actor = who.userId;
    r.connector = connector.strip;
    r.url = url.strip;
    return encode(ports.accessRules.checkAccess(r), true);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  ConnectivityConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("cli");

  // connectors, rules by connector name
  auto connector = registry.byPath("connectors").create(who, parseJsonString(
      `{"name": "dc1", "locationId": "fra", "host": "scc.corp", "port": "8443"}`));
  assert(connector["status"].get!string == "connected");
  auto rules = registry.byPath("access-rules");
  auto rule = rules.create(who, registry.withReferences(who.tenantId, parseJsonString(
      `{"connectorId": "dc1", "virtualHost": "erp.virtual", "virtualPort": 443, "urlPathPrefix": "/sap"}`)));
  assert(rule["connectorId"].get!string == connector["id"].get!string);
  assert(rule["includeSubPaths"].get!bool);

  // secrets masked; PATCH with the mask keeps the stored secret
  auto destinations = registry.byPath("destinations");
  auto d = destinations.create(who, parseJsonString(`{"name": "ERP", "url": "https://erp.virtual/sap/opu",
    "proxyType": "onPremise", "cloudConnectorLocationId": "fra", "authenticationType": "basicAuthentication",
    "user": "RFC_USER", "password": "s3cret", "properties": "sap-client=100"}`));
  assert(d["password"].get!string == secretMask);
  assert(d["properties"][0]["value"].get!string == "100");
  auto patched = destinations.update(who, d["id"].get!string, parseJsonString(`{"description": "x", "password": "********"}`));
  assert(patched["description"].get!string == "x" && patched["status"].get!string == "unchecked");
  assert(registry.ports.destinations.get(who.tenantId, DestinationId(d["id"].get!string)).password == "s3cret");

  auto checked = destinations.invoke(who, d["id"].get!string, "check", Json.emptyObject);
  assert(checked["status"].get!string == "reachable", checked["statusMessage"].get!string);

  // business errors become ResourceErrors with HTTP status
  int status;
  try destinations.create(who, parseJsonString(`{"name": "ERP", "url": "https://x"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 409);

  ResourceAction action;
  assert(registry.byODataAction("StartMaintenanceCloudConnector", action) is registry.byPath("connectors"));
  assert(registry.byODataAction("RenewCertificate", action) !is null && action.parameters == ["validDays"]);

  assert(registry.checkAccess(who, "dc1", "https://erp.virtual/sap/opu")["allowed"].get!bool);
  assert(!registry.checkAccess(who, "dc1", "https://erp.virtual/other")["allowed"].get!bool);
  assert(destinations.list(who.tenantId, ["proxyType": "onPremise"]).length == 1);
  assert(registry.statistics(who.tenantId)["destinationsReachable"].get!long == 1);
  assert(registry.healthCheck(who.tenantId)["examined"].get!long >= 2);

  auto logs = registry.byPath("logs");
  assert(!logs.updatable && logs.list(who.tenantId).length > 0);
  status = 0;
  try logs.update(who, logs.list(who.tenantId)[0]["id"].get!string, parseJsonString(`{"message": "x"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 405);
  assert(registry.bySet("ServiceChannels").inputFields[0].name == "connectorId");
}

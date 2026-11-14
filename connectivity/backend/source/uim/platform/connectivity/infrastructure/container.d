/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.infrastructure.container;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  ConnectivityConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  ConnectivityRepositories repositories;
  IConnectivityEventPublisher publisher;
  SimulatedConnectivityProbe probe;

  // ── Application services ──────────────────────────────────────────────
  EventRecorder events;
  ConnectorCascade cascade;
  DestinationChecker checker;

  // ── Driving ports ─────────────────────────────────────────────────────
  ConnectivityPorts ports;

  this(ConnectivityConfig config) {
    this.config = config;
    wirePersistence();
    wireApplication();
  }

  protected void wirePersistence() {
    if (config.usesFileStorage)
      storage = new JsonFileSnapshotStorage(config.dataDir);

    auto store(TEntity, TId)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, RecordMapper!TEntity)(storage, collection);
      return s;
    }

    with (repositories) {
      destinations = new DestinationRepository(store!(Destination, DestinationId)(ConnectivityCollections.destinations));
      connectors = new ConnectorRepository(store!(CloudConnector, ConnectorId)(ConnectivityCollections.connectors));
      channels = new ChannelRepository(store!(ServiceChannel, ChannelId)(ConnectivityCollections.channels));
      accessRules = new AccessRuleRepository(store!(AccessRule, AccessRuleId)(ConnectivityCollections.accessRules));
      certificates = new CertificateRepository(store!(Certificate, CertificateId)(ConnectivityCollections.certificates));
      logs = new LogRepository(store!(ConnectivityLogEntry, LogEntryId)(ConnectivityCollections.logs));
    }
    publisher = new LogEventPublisher();
    probe = new SimulatedConnectivityProbe();
  }

  protected void wireApplication() {
    auto r = repositories;
    auto policy = config.policy;
    events = new EventRecorder(r.logs, publisher);
    cascade = new ConnectorCascade(r, events);
    checker = new DestinationChecker(r, probe, events, policy);

    ports.destinations = new ManageDestinationsUseCase(r, events, checker);
    ports.connectors = new ManageConnectorsUseCase(r, events, cascade);
    ports.channels = new ManageChannelsUseCase(r, events);
    ports.accessRules = new ManageAccessRulesUseCase(r, events);
    ports.certificates = new ManageCertificatesUseCase(r, events, policy);
    ports.logs = new ManageLogsUseCase(r, events);
    ports.healthCheck = new HealthCheckUseCase(r, events, checker, cascade, policy);
    ports.statistics = new ConnectivityStatisticsService(r);
  }
}

/// Build the full dependency graph.
Container buildContainer(ConnectivityConfig config) {
  return new Container(config);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  ConnectivityConfig cfg;
  cfg.storage = "memory";
  cfg.heartbeatTimeoutSeconds = 60;
  auto c = buildContainer(cfg);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto who = UserId("jane");

  // ── certificate store ─────────────────────────────────────────────────
  CreateCertificateRequest cert;
  cert.tenantId = t;
  cert.actor = who;
  cert.spec.name = "erp-client";
  cert.spec.subjectDN = "CN=erp-client";
  assert(p.certificates.create(cert).code == 422); // no expiry
  cert.spec.expiresAt = nowStdTime() + 365 * stdTimeDay;
  cert.spec.fingerprint = "zz";
  assert(p.certificates.create(cert).code == 422); // bad fingerprint
  cert.spec.fingerprint = "";
  auto certResult = p.certificates.create(cert);
  assert(certResult.isSuccess, certResult.message);
  auto certId = CertificateId(certResult.id);
  assert(p.certificates.get(t, certId).status == CertificateStatus.valid);
  assert(p.certificates.create(cert).code == 409); // duplicate name

  // ── internet destination ──────────────────────────────────────────────
  CreateDestinationRequest api;
  api.tenantId = t;
  api.actor = who;
  api.spec.name = "PUBLIC API";
  api.spec.url = "https://api.example.com/v1";
  assert(p.destinations.create(api).code == 422); // blank in name
  api.spec.name = "PUBLIC_API";
  api.spec.authenticationType = AuthenticationType.oauth2ClientCredentials;
  assert(p.destinations.create(api).code == 422); // clientId, secret, token service missing
  api.spec.clientId = "cid";
  api.spec.clientSecret = "secret";
  api.spec.tokenServiceUrl = "https://auth.example.com/oauth/token";
  auto apiResult = p.destinations.create(api);
  assert(apiResult.isSuccess, apiResult.message);
  auto apiId = DestinationId(apiResult.id);
  assert(p.destinations.check(t, apiId, who).isSuccess);
  assert(p.destinations.get(t, apiId).status == DestinationStatus.reachable);
  assert(!p.destinations.findByName(t, "PUBLIC_API").isNull);

  // ── Cloud Connector, access rule, on-premise destination ──────────────
  RegisterConnectorRequest reg;
  reg.tenantId = t;
  reg.actor = who;
  reg.spec.subaccountId = SubaccountId("sa1");
  reg.spec.name = "Frankfurt DC";
  reg.spec.locationId = "fra";
  reg.spec.host = "scc.corp.local";
  auto ccResult = p.connectors.create(reg);
  assert(ccResult.isSuccess, ccResult.message);
  auto ccId = ConnectorId(ccResult.id);
  reg.spec.name = "Other";
  assert(p.connectors.create(reg).code == 409); // location in use

  CreateDestinationRequest erp;
  erp.tenantId = t;
  erp.actor = who;
  erp.spec.name = "ERP_ODATA";
  erp.spec.url = "https://erp.virtual:443/sap/opu/odata/sap/API_BUSINESS_PARTNER";
  erp.spec.proxyType = ProxyType.onPremise;
  erp.spec.cloudConnectorLocationId = "fra";
  erp.spec.authenticationType = AuthenticationType.clientCertificateAuthentication;
  erp.spec.certificateId = CertificateId("erp-client"); // by name
  auto erpResult = p.destinations.create(erp);
  assert(erpResult.isSuccess, erpResult.message);
  auto erpId = DestinationId(erpResult.id);
  assert(p.destinations.get(t, erpId).certificateId == certId);

  p.destinations.check(t, erpId, who);
  auto erpDest = p.destinations.get(t, erpId);
  assert(erpDest.status == DestinationStatus.unreachable && erpDest.statusMessage.canFind("No access rule"), erpDest.statusMessage);

  CreateAccessRuleRequest rule;
  rule.tenantId = t;
  rule.actor = who;
  rule.parentId = ccId;
  rule.spec.virtualHost = "ERP.virtual";
  rule.spec.virtualPort = 443;
  rule.spec.internalHost = "erp.corp.local";
  rule.spec.internalPort = 44_300;
  rule.spec.urlPathPrefix = "/sap/opu/odata/";
  auto ruleResult = p.accessRules.create(rule);
  assert(ruleResult.isSuccess, ruleResult.message);
  auto ruleId = AccessRuleId(ruleResult.id);
  assert(p.accessRules.get(t, ruleId).name == "https://erp.virtual:443/sap/opu/odata");
  assert(p.accessRules.create(rule).code == 409); // same resource

  p.destinations.check(t, erpId, who);
  erpDest = p.destinations.get(t, erpId);
  assert(erpDest.status == DestinationStatus.reachable, erpDest.statusMessage);
  assert(erpDest.statusMessage.canFind("Frankfurt DC"));
  assert(c.probe.operations.any!(o => o.target == "erp.corp.local:44300"));

  AccessCheckRequest probe;
  probe.tenantId = t;
  probe.actor = who;
  probe.connector = "Frankfurt DC";
  probe.url = "https://erp.virtual/sap/opu/odata/sap/X";
  assert(p.accessRules.checkAccess(probe).allowed);
  probe.url = "https://erp.virtual/sap/bc/gui";
  assert(!p.accessRules.checkAccess(probe).allowed);
  assert(p.accessRules.disable(t, ruleId, who).isSuccess);
  assert(p.accessRules.disable(t, ruleId, who).code == 409);
  assert(p.accessRules.enable(t, ruleId, who).isSuccess);

  // ── service channel ───────────────────────────────────────────────────
  CreateChannelRequest ch;
  ch.tenantId = t;
  ch.actor = who;
  ch.parentId = ccId;
  ch.spec.name = "ERP HTTP";
  ch.spec.virtualHost = "erp.virtual";
  ch.spec.virtualPort = 8000;
  ch.spec.backendHost = "erp.corp.local";
  ch.spec.backendPort = 8000;
  auto chResult = p.channels.create(ch);
  assert(chResult.isSuccess, chResult.message);
  auto chId = ChannelId(chResult.id);
  ch.spec.name = "Duplicate endpoint";
  assert(p.channels.create(ch).code == 409);
  assert(p.channels.open(t, chId, who).isSuccess);
  assert(p.channels.open(t, chId, who).code == 409);
  assert(p.channels.remove(t, chId, who).code == 409); // open
  assert(p.connectors.remove(t, ccId, who).code == 409); // open channel

  // maintenance closes channels
  assert(p.connectors.startMaintenance(t, ccId, who).isSuccess);
  assert(p.channels.get(t, chId).status == ChannelStatus.closed);
  assert(p.channels.open(t, chId, who).code == 409); // connector not connected
  assert(p.connectors.reconnect(t, ccId, who).isSuccess);
  assert(p.channels.open(t, chId, who).isSuccess);

  // ── health check: missed heartbeat ────────────────────────────────────
  auto connector = c.repositories.connectors.findById(t, ccId);
  connector.lastHeartbeatAt = connector.connectedAt = nowStdTime() - 120 * 10_000_000L;
  c.repositories.connectors.update(connector);
  auto report = p.healthCheck.run(t);
  assert(report.changes.any!(x => x.canFind("heartbeat missed")), report.changes.join("; "));
  assert(p.connectors.get(t, ccId).status == ConnectorStatus.disconnected);
  assert(p.channels.get(t, chId).status == ChannelStatus.closed);
  assert(p.destinations.get(t, erpId).status == DestinationStatus.unreachable);
  assert(p.connectors.heartbeat(t, ccId, "2.18.1", who).isSuccess);
  assert(p.connectors.get(t, ccId).status == ConnectorStatus.connected);
  assert(p.connectors.get(t, ccId).connectorVersion == "2.18.1");
  p.healthCheck.run(t);
  assert(p.destinations.get(t, erpId).status == DestinationStatus.reachable);

  // ── certificate lifecycle ─────────────────────────────────────────────
  assert(p.certificates.remove(t, certId, who).code == 409); // used by ERP_ODATA
  auto stored = c.repositories.certificates.findById(t, certId);
  stored.expiresAt = nowStdTime() + 5 * stdTimeDay;
  c.repositories.certificates.update(stored);
  p.healthCheck.run(t);
  assert(p.certificates.get(t, certId).status == CertificateStatus.expiring);
  assert(p.certificates.renew(t, certId, 400, who).isSuccess);
  assert(p.certificates.get(t, certId).status == CertificateStatus.valid);
  assert(p.certificates.revoke(t, certId, who).isSuccess);
  assert(p.certificates.renew(t, certId, 30, who).code == 409);
  p.destinations.check(t, erpId, who);
  assert(p.destinations.get(t, erpId).status == DestinationStatus.misconfigured);

  // ── statistics and log ────────────────────────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.destinations == 2 && stats.destinationsReachable == 1 && stats.destinationsMisconfigured == 1);
  assert(stats.connectors == 1 && stats.connectorsConnected == 1 && stats.channels == 1 && stats.accessRules == 1);
  assert(stats.certificatesExpired == 1 && stats.logEntries > 5 && stats.warnings > 0);
  assert(p.logs.bySource(t, ccId.value).length >= 4);

  CreateLogEntryRequest ext;
  ext.tenantId = t;
  ext.actor = who;
  ext.spec.eventType = ConnectivityEventType.authenticationFailure;
  ext.spec.severity = LogSeverity.error;
  ext.spec.sourceName = "SCC";
  assert(p.logs.create(ext).code == 422); // no message
  ext.spec.message = "SNC handshake failed";
  auto logResult = p.logs.create(ext);
  assert(logResult.isSuccess, logResult.message);
  UpdateLogEntryRequest change;
  change.tenantId = t;
  change.id = LogEntryId(logResult.id);
  assert(p.logs.update(change).code == 409); // immutable

  // ── unregister cascades ───────────────────────────────────────────────
  assert(p.connectors.disconnect(t, ccId, who).isSuccess);
  assert(p.connectors.remove(t, ccId, who).isSuccess);
  assert(p.channels.list(t).length == 0 && p.accessRules.list(t).length == 0);
  assert(p.logs.purge(t, nowStdTime() + 1, who) > 0);
  assert(p.logs.list(t).length == 0);
}

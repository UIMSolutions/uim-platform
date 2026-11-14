/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.persistence.repositories.repositories;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

class DestinationRepository : ConnectivityRepository!(Destination, DestinationId), IDestinationRepository {
  this() {
    super();
  }

  this(ITenantStore!(Destination, DestinationId) store) {
    super(store);
  }

  Destination findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  Destination[] findByCertificate(TenantId tenantId, CertificateId certificateId) {
    return where(tenantId, (e) => e.certificateId == certificateId);
  }

  Destination[] findByLocation(TenantId tenantId, string locationId) {
    return where(tenantId, (e) => e.proxyType == ProxyType.onPremise && e.cloudConnectorLocationId == locationId);
  }
}

class ConnectorRepository : ConnectivityRepository!(CloudConnector, ConnectorId), IConnectorRepository {
  this() {
    super();
  }

  this(ITenantStore!(CloudConnector, ConnectorId) store) {
    super(store);
  }

  CloudConnector findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  CloudConnector findByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId) {
    return first(tenantId, (e) => e.locationId == locationId && (subaccountId.isEmpty || e.subaccountId == subaccountId));
  }
}

/// Repository of an aggregate that belongs to one Cloud Connector.
class ConnectorScopedRepository(TEntity, TId) : ConnectivityRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, ConnectorId connectorId, string name) {
    return first(tenantId, (e) => e.connectorId == connectorId && e.name == name);
  }

  TEntity[] findByConnector(TenantId tenantId, ConnectorId connectorId) {
    return where(tenantId, (e) => e.connectorId == connectorId);
  }
}

class ChannelRepository : ConnectorScopedRepository!(ServiceChannel, ChannelId), IChannelRepository {
  this() {
    super();
  }

  this(ITenantStore!(ServiceChannel, ChannelId) store) {
    super(store);
  }
}

class AccessRuleRepository : ConnectorScopedRepository!(AccessRule, AccessRuleId), IAccessRuleRepository {
  this() {
    super();
  }

  this(ITenantStore!(AccessRule, AccessRuleId) store) {
    super(store);
  }
}

class CertificateRepository : ConnectivityRepository!(Certificate, CertificateId), ICertificateRepository {
  this() {
    super();
  }

  this(ITenantStore!(Certificate, CertificateId) store) {
    super(store);
  }

  Certificate findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }
}

class LogRepository : ConnectivityRepository!(ConnectivityLogEntry, LogEntryId), ILogRepository {
  this() {
    super();
  }

  this(ITenantStore!(ConnectivityLogEntry, LogEntryId) store) {
    super(store);
  }

  ConnectivityLogEntry[] findBySource(TenantId tenantId, string sourceId) {
    return where(tenantId, (e) => e.sourceId == sourceId);
  }

  ConnectivityLogEntry[] findBySeverity(TenantId tenantId, LogSeverity severity) {
    return where(tenantId, (e) => e.severity == severity);
  }
}

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new DestinationRepository()));
  assert(tenantRepositoryTest(new ConnectorRepository()));
  assert(tenantRepositoryTest(new ChannelRepository()));
  assert(tenantRepositoryTest(new LogRepository()));

  auto t = TenantId("t1");
  auto connectors = new ConnectorRepository();
  auto c = CloudConnector(t);
  c.name = "dc1";
  c.subaccountId = SubaccountId("sa1");
  c.locationId = "fra";
  connectors.save(c);
  assert(!connectors.findByLocation(t, SubaccountId("sa1"), "fra").isNull);
  assert(!connectors.findByLocation(t, SubaccountId.init, "fra").isNull);
  assert(connectors.findByLocation(t, SubaccountId("sa2"), "fra").isNull);

  auto rules = new AccessRuleRepository();
  auto r = AccessRule(t);
  r.connectorId = c.id;
  r.name = "erp";
  rules.save(r);
  assert(!rules.findByName(t, c.id, "erp").isNull);
  assert(rules.findByName(t, ConnectorId("other"), "erp").isNull);
  assert(rules.findByConnector(t, c.id).length == 1);
}

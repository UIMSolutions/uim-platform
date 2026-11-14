/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.ports.repositories.repositories;

import uim.platform.connectivity;

mixin(ShowModule!());

@safe:

interface IDestinationRepository : ITenantRepository!(Destination, DestinationId) {
  Destination findByName(TenantId tenantId, string name);
  Destination[] findByCertificate(TenantId tenantId, CertificateId certificateId);
  Destination[] findByLocation(TenantId tenantId, string locationId);
}

interface IConnectorRepository : ITenantRepository!(CloudConnector, ConnectorId) {
  CloudConnector findByName(TenantId tenantId, string name);
  /// The connector of a location within a subaccount (empty subaccount = any).
  CloudConnector findByLocation(TenantId tenantId, SubaccountId subaccountId, string locationId);
}

/// Persistence of aggregates that belong to one Cloud Connector (names unique per connector).
interface IConnectorScopedRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity findByName(TenantId tenantId, ConnectorId connectorId, string name);
  TEntity[] findByConnector(TenantId tenantId, ConnectorId connectorId);
}

interface IChannelRepository : IConnectorScopedRepository!(ServiceChannel, ChannelId) {
}

interface IAccessRuleRepository : IConnectorScopedRepository!(AccessRule, AccessRuleId) {
}

interface ICertificateRepository : ITenantRepository!(Certificate, CertificateId) {
  Certificate findByName(TenantId tenantId, string name);
}

interface ILogRepository : ITenantRepository!(ConnectivityLogEntry, LogEntryId) {
  ConnectivityLogEntry[] findBySource(TenantId tenantId, string sourceId);
  ConnectivityLogEntry[] findBySeverity(TenantId tenantId, LogSeverity severity);
}

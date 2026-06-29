/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.application.usecases.manage.connectors;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.ports.repositories.connectors;
// import uim.platform.connectivity.domain.ports.repositories.connectivity_logs;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

// mixin(ShowModule!());

@safe:
/// Application service for Cloud Connector registration and lifecycle.
class ManageConnectorsUseCase { // TODO: UIMUseCase {
  private ConnectorRepository repo;
  private ConnectivityLogRepository logRepo;

  this(ConnectorRepository repo, ConnectivityLogRepository logRepo) {
    this.repo = repo;
    this.logRepo = logRepo;
  }

  CommandResult registerConnector(RegisterConnectorRequest req) {
    // Check for duplicate location ID within subaccount
    if (repo.existsByLocation(req.tenantId, req.subaccountId, req.locationId))
      return CommandResult(false, "",
          "Connector with locationId '" ~ req.locationId ~ "' already registered");

    auto cc = CloudConnector(req.tenantId);
    cc.subaccountId = req.subaccountId;
    cc.locationId = req.locationId;
    cc.description = req.description;
    cc.connectorVersion = req.connectorVersion;
    cc.host = req.host;
    cc.port = req.port;
    cc.status = ConnectorStatus.connected;
    cc.tunnelEndpoint = req.tunnelEndpoint;

    repo.save(cc);
    // Record connection event
    recordLog(req.tenantId, ConnectivityEventType.connectionEstablished, cc.id.value,
        "CloudConnector", "Connector registered: " ~ req.locationId);

    return CommandResult(true, cc.id.value, "");
  }

  CommandResult heartbeat(TenantId tenantId, ConnectorId id, HeartbeatRequest req) {
    auto cc = repo.findById(tenantId, id);
    if (cc.isNull)
      return CommandResult(false, "", "Connector not found");

    cc.status = ConnectorStatus.connected;
    if (req.connectorVersion.length > 0)
      cc.connectorVersion = req.connectorVersion;

    repo.update(cc);
    return CommandResult(true, cc.id.value, "");
  }

  CommandResult disconnect(TenantId tenantId, ConnectorId id) {
    auto connector = repo.findById(tenantId, id);
    if (connector.isNull)
      return CommandResult(false, "", "Connector not found");

    connector.status = ConnectorStatus.disconnected;
    repo.update(connector);

    recordLog(connector.tenantId, ConnectivityEventType.connectionLost, connector.id.value,
        "CloudConnector", "Connector disconnected: " ~ connector.locationId);

    return CommandResult(true, connector.id.value, "");
  }
  
  CloudConnector getConnector(TenantId tenantId, ConnectorId id) {
    return repo.findById(tenantId, id);
  }

  CloudConnector[] listBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return repo.findBySubaccount(tenantId, subaccountId);
  }
  CloudConnector[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult unregister(TenantId tenantId, ConnectorId id) {
    auto connector = repo.findById(tenantId, id);
    if (connector.isNull)
      return CommandResult(false, "", "Connector not found");

    repo.remove(connector);

    recordLog(connector.tenantId, ConnectivityEventType.connectionLost, id.value,
        "CloudConnector", "Connector unregistered: " ~ connector.locationId);

    return CommandResult(true, connector.id.value, "");
  }

  private void recordLog(TenantId tenantId, ConnectivityEventType evtType,
      string sourceId, string sourceType, string message) {
   
    auto entry = ConnectivityLog(tenantId);
    entry.eventType = evtType;
    entry.severity = LogSeverity.info;
    entry.sourceId = sourceId;
    entry.sourceType = sourceType;
    entry.message = message;

    logRepo.save(entry);
  }
}

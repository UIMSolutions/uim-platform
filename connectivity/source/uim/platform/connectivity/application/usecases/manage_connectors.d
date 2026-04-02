module uim.platform.connectivity.application.usecases.manage_connectors;

// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.entities.connectivity_log;
// import uim.platform.connectivity.domain.ports.connector_repository;
// import uim.platform.connectivity.domain.ports.connectivity_log_repository;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Application service for Cloud Connector registration and lifecycle.
class ManageConnectorsUseCase {
    private ConnectorRepository repo;
    private ConnectivityLogRepository logRepo;

    this(ConnectorRepository repo, ConnectivityLogRepository logRepo) {
        this.repo = repo;
        this.logRepo = logRepo;
    }

    CommandResult registerConnector(RegisterConnectorRequest req) {
        // Check for duplicate location ID within subaccount
        auto existing = repo.findByLocationId(req.subaccountId, req.locationId);
        if (existing.id.length > 0)
            return CommandResult(false, "", "Connector with locationId '" ~ req.locationId ~ "' already registered");

        import std.uuid : randomUUID;

        auto id = randomUUID().toString();

        CloudConnector cc;
        cc.id = id;
        cc.subaccountId = req.subaccountId;
        cc.tenantId = req.tenantId;
        cc.locationId = req.locationId;
        cc.description = req.description;
        cc.connectorVersion = req.connectorVersion;
        cc.host = req.host;
        cc.port = req.port;
        cc.status = ConnectorStatus.connected;
        cc.tunnelEndpoint = req.tunnelEndpoint;

        repo.save(cc);

        // Record connection event
        recordLog(req.tenantId, ConnectivityEventType.connectionEstablished,
            id, "CloudConnector", "Connector registered: " ~ req.locationId);

        return CommandResult(true, id, "");
    }

    CommandResult heartbeat(ConnectorId id, HeartbeatRequest req) {
        auto cc = repo.findById(id);
        if (cc.id.length == 0)
            return CommandResult(false, "", "Connector not found");

        cc.status = ConnectorStatus.connected;
        if (req.connectorVersion.length > 0)
            cc.connectorVersion = req.connectorVersion;

        repo.update(cc);
        return CommandResult(true, id, "");
    }

    CommandResult disconnect(ConnectorId id) {
        auto cc = repo.findById(id);
        if (cc.id.length == 0)
            return CommandResult(false, "", "Connector not found");

        cc.status = ConnectorStatus.disconnected;
        repo.update(cc);

        recordLog(cc.tenantId, ConnectivityEventType.connectionLost,
            id, "CloudConnector", "Connector disconnected: " ~ cc.locationId);

        return CommandResult(true, id, "");
    }

    CloudConnector getConnector(ConnectorId id) {
        return repo.findById(id);
    }

    CloudConnector[] listBySubaccount(SubaccountId subaccountId) {
        return repo.findBySubaccount(subaccountId);
    }

    CloudConnector[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult unregister(ConnectorId id) {
        auto cc = repo.findById(id);
        if (cc.id.length == 0)
            return CommandResult(false, "", "Connector not found");

        repo.remove(id);

        recordLog(cc.tenantId, ConnectivityEventType.connectionLost,
            id, "CloudConnector", "Connector unregistered: " ~ cc.locationId);

        return CommandResult(true, id, "");
    }

    private void recordLog(TenantId tenantId, ConnectivityEventType evtType,
        string sourceId, string sourceType, string message) {
        import std.uuid : randomUUID;

        ConnectivityLog entry;
        entry.id = randomUUID().toString();
        entry.tenantId = tenantId;
        entry.eventType = evtType;
        entry.severity = LogSeverity.info;
        entry.sourceId = sourceId;
        entry.sourceType = sourceType;
        entry.message = message;
        logRepo.save(entry);
    }
}

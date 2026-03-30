module domain.entities.cloud_connector;

import domain.types;

/// On-premise Cloud Connector registration.
struct CloudConnector
{
    ConnectorId id;
    SubaccountId subaccountId;
    TenantId tenantId;
    string locationId;            // distinguishes multiple CCs per subaccount
    string description;
    string connectorVersion;
    string host;
    ushort port;
    ConnectorStatus status = ConnectorStatus.disconnected;
    long lastHeartbeat;
    long connectedSince;
    string tunnelEndpoint;        // internal tunnel address
    long createdAt;
    long updatedAt;
}

module uim.platform.connectivity.domain.ports.connector_repository;

import uim.platform.connectivity.domain.entities.cloud_connector;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - cloud connector persistence.
interface ConnectorRepository {
    CloudConnector findById(ConnectorId id);
    CloudConnector findByLocationId(SubaccountId subaccountId, string locationId);
    CloudConnector[] findBySubaccount(SubaccountId subaccountId);
    CloudConnector[] findByTenant(TenantId tenantId);
    void save(CloudConnector connector);
    void update(CloudConnector connector);
    void remove(ConnectorId id);
}

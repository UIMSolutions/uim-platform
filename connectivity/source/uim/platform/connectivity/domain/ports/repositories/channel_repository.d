module uim.platform.connectivity.domain.ports.channel_repository;

import uim.platform.connectivity.domain.entities.service_channel;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - service channel persistence.
interface ChannelRepository {
    ServiceChannel findById(ChannelId id);
    ServiceChannel[] findByConnector(ConnectorId connectorId);
    ServiceChannel[] findByTenant(TenantId tenantId);
    ServiceChannel[] findByStatus(TenantId tenantId, ChannelStatus status);
    void save(ServiceChannel channel);
    void update(ServiceChannel channel);
    void remove(ChannelId id);
}

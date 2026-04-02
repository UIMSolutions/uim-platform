module uim.platform.connectivity.infrastructure.persistence.memory.connector_repo;

// import uim.platform.connectivity.domain.types;
// import uim.platform.connectivity.domain.entities.cloud_connector;
// import uim.platform.connectivity.domain.ports.connector_repository;
// 
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class MemoryConnectorRepository : ConnectorRepository {
    private CloudConnector[ConnectorId] store;

    CloudConnector findById(ConnectorId id) {
        if (auto p = id in store)
            return *p;
        return CloudConnector.init;
    }

    CloudConnector findByLocationId(SubaccountId subaccountId, string locationId) {
        foreach (ref e; store.byValue())
            if (e.subaccountId == subaccountId && e.locationId == locationId)
                return e;
        return CloudConnector.init;
    }

    CloudConnector[] findBySubaccount(SubaccountId subaccountId) {
        return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
    }

    CloudConnector[] findByTenant(TenantId tenantId) {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(CloudConnector entity) {
        store[entity.id] = entity;
    }

    void update(CloudConnector entity) {
        store[entity.id] = entity;
    }

    void remove(ConnectorId id) {
        store.remove(id);
    }
}

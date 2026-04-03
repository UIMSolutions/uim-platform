module uim.platform.abap_enviroment.infrastructure.persistence.memory.transport_request_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.transport_request;
// import uim.platform.abap_enviroment.domain.ports.transport_request_repository;
// 
// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.abap_enviroment;
mixin(ShowModule!());
@safe:

class MemoryTransportRequestRepository : TransportRequestRepository {
    private TransportRequest[TransportRequestId] store;

    TransportRequest* findById(TransportRequestId id) {
        if (auto p = id in store)
            return p;
        return null;
    }

    TransportRequest[] findBySystem(SystemInstanceId systemId) {
        return store.byValue().filter!(e => e.sourceSystemId == systemId).array;
    }

    TransportRequest[] findByTenant(TenantId tenantId) {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    TransportRequest[] findByStatus(SystemInstanceId systemId, TransportStatus status) {
        return store.byValue()
            .filter!(e => e.sourceSystemId == systemId && e.status == status)
            .array;
    }

    TransportRequest[] findByOwner(SystemInstanceId systemId, string owner) {
        return store.byValue()
            .filter!(e => e.sourceSystemId == systemId && e.owner == owner)
            .array;
    }

    void save(TransportRequest request) {
        store[request.id] = request;
    }

    void update(TransportRequest request) {
        store[request.id] = request;
    }

    void remove(TransportRequestId id) {
        store.remove(id);
    }
}

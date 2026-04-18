/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.content_connectors;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryContentConnectorRepository : ContentConnectorRepository {
    private ContentConnector[] store;

    bool existsById(ContentConnectorId id) {
        return store.any!(e => e.id == id);
    }

    ContentConnector findById(ContentConnectorId id) {
        foreach (e; store)
            if (e.id == id) return e;
        return ContentConnector.init;
    }

    ContentConnector[] findAll() { return store; }

    ContentConnector[] findByTenant(TenantId tenantId) {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ContentConnector[] findByType(ConnectorType connectorType) {
        return store.filter!(e => e.connectorType == connectorType).array;
    }

    ContentConnector[] findByStatus(ConnectorStatus status) {
        return store.filter!(e => e.status == status).array;
    }

    void save(ContentConnector connector) { store ~= connector; }

    void update(ContentConnector connector) {
        foreach (ref e; store)
            if (e.id == connector.id) { e = connector; return; }
    }

    void remove(ContentConnectorId id) {
        import std.algorithm : remove;
        store = store.remove!(e => e.id == id);
    }
}

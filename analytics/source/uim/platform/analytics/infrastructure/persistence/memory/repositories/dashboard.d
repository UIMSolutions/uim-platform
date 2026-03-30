module analytics.infrastructure.persistence.memory.repositories.dashboard;

import analytics.domain.entities.dashboard;
import analytics.domain.repositories.dashboard;
import analytics.domain.values.common;

/// In-memory adapter implementing DashboardRepository port.
class InMemoryDashboardRepository : DashboardRepository {
    private Dashboard[string] store;

    Dashboard findById(EntityId id) {
        if (auto p = id.value in store)
            return *p;
        return null;
    }

    Dashboard[] findByOwner(EntityId ownerId) {
        Dashboard[] result;
        foreach (d; store.byValue())
            if (d.ownerId == ownerId)
                result ~= d;
        return result;
    }

    Dashboard[] findByStatus(ArtifactStatus status) {
        Dashboard[] result;
        foreach (d; store.byValue())
            if (d.status == status)
                result ~= d;
        return result;
    }

    Dashboard[] findAll() {
        return store.values;
    }

    void save(Dashboard dashboard) {
        store[dashboard.id.value] = dashboard;
    }

    void remove(EntityId id) {
        store.remove(id.value);
    }
}

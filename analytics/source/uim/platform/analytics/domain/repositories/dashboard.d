module uim.platform.analytics.domain.repositories.dashboard;

import analytics.domain.entities.dashboard;
import analytics.domain.values.common;

/// Port: outgoing repository interface for Dashboard persistence.
interface DashboardRepository {
    Dashboard findById(EntityId id);
    Dashboard[] findByOwner(EntityId ownerId);
    Dashboard[] findByStatus(ArtifactStatus status);
    Dashboard[] findAll();
    void save(Dashboard dashboard);
    void remove(EntityId id);
}

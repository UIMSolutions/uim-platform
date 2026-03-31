module uim.platform.analytics.domain.repositories.dashboard;

import uim.platform.analytics.domain.entities.dashboard;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// Port: outgoing repository interface for Dashboard persistence.
interface DashboardRepository {
    Dashboard findById(EntityId id);
    Dashboard[] findByOwner(EntityId ownerId);
    Dashboard[] findByStatus(ArtifactStatus status);
    Dashboard[] findAll();
    void save(Dashboard dashboard);
    void remove(EntityId id);
}

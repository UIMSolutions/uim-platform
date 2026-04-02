module uim.platform.content_agent.domain.ports.content_activity_repository;

import domain.entities.content_activity;
import domain.types;

/// Port: outgoing - content activity (audit log) persistence.
interface ContentActivityRepository
{
    ContentActivity findById(ContentActivityId id);
    ContentActivity[] findByTenant(TenantId tenantId);
    ContentActivity[] findByEntity(string entityId);
    ContentActivity[] findByType(TenantId tenantId, ActivityType activityType);
    ContentActivity[] findRecent(TenantId tenantId, int limit);
    void save(ContentActivity activity);
}

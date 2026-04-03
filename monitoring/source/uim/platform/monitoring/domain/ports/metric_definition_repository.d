module uim.platform.xyz.domain.ports.metric_definition_repository;

import uim.platform.xyz.domain.entities.metric_definition;
import uim.platform.xyz.domain.types;

/// Port: outgoing - metric definition persistence.
interface MetricDefinitionRepository
{
    MetricDefinition findById(MetricDefinitionId id);
    MetricDefinition[] findByTenant(TenantId tenantId);
    MetricDefinition[] findByCategory(TenantId tenantId, MetricCategory category);
    MetricDefinition findByName(TenantId tenantId, string name);
    void save(MetricDefinition def);
    void update(MetricDefinition def);
    void remove(MetricDefinitionId id);
}

module domain.ports.metric_definition_repository;

import domain.entities.metric_definition;
import domain.types;

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

module domain.ports.access_rule_repository;

import domain.entities.access_rule;
import domain.types;

/// Port: outgoing - access rule persistence.
interface AccessRuleRepository
{
    AccessRule findById(RuleId id);
    AccessRule[] findByConnector(ConnectorId connectorId);
    AccessRule[] findByTenant(TenantId tenantId);
    void save(AccessRule rule);
    void update(AccessRule rule);
    void remove(RuleId id);
}

module uim.platform.connectivity.domain.ports.repositories.access_rule_repository;

import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity.domain.types;

/// Port: outgoing - access rule persistence.
interface AccessRuleRepository
{
  bool existsId(RuleId id);
  AccessRule findById(RuleId id);
  AccessRule[] findByConnector(ConnectorId connectorId);
  AccessRule[] findByTenant(TenantId tenantId);
  void save(AccessRule rule);
  void update(AccessRule rule);
  void remove(RuleId id);
}

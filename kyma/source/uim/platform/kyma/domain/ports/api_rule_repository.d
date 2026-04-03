module uim.platform.xyz.domain.ports.api_rule_repository;

import uim.platform.xyz.domain.entities.api_rule;
import uim.platform.xyz.domain.types;

/// Port: outgoing — API rule persistence.
interface ApiRuleRepository
{
    ApiRule findById(ApiRuleId id);
    ApiRule findByName(NamespaceId nsId, string name);
    ApiRule[] findByNamespace(NamespaceId nsId);
    ApiRule[] findByEnvironment(KymaEnvironmentId envId);
    ApiRule[] findByStatus(ApiRuleStatus status);
    void save(ApiRule rule);
    void update(ApiRule rule);
    void remove(ApiRuleId id);
}

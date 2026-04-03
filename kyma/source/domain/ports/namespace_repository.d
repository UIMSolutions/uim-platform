module uim.platform.xyz.domain.ports.namespace_repository;

import domain.entities.namespace;
import domain.types;

/// Port: outgoing — namespace persistence.
interface NamespaceRepository
{
    Namespace findById(NamespaceId id);
    Namespace findByName(KymaEnvironmentId envId, string name);
    Namespace[] findByEnvironment(KymaEnvironmentId envId);
    Namespace[] findByTenant(TenantId tenantId);
    void save(Namespace ns);
    void update(Namespace ns);
    void remove(NamespaceId id);
}

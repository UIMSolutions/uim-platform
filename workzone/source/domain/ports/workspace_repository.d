module domain.ports.workspace_repository;

import domain.types;
import domain.entities.workspace;

interface WorkspaceRepository
{
    Workspace[] findByTenant(TenantId tenantId);
    Workspace* findById(WorkspaceId id, TenantId tenantId);
    Workspace* findByAlias(string alias_, TenantId tenantId);
    Workspace[] findByMember(UserId userId, TenantId tenantId);
    void save(Workspace workspace);
    void update(Workspace workspace);
    void remove(WorkspaceId id, TenantId tenantId);
}

module domain.ports.workpage_repository;

import domain.types;
import domain.entities.workpage;

interface WorkpageRepository
{
    Workpage[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Workpage* findById(WorkpageId id, TenantId tenantId);
    void save(Workpage page);
    void update(Workpage page);
    void remove(WorkpageId id, TenantId tenantId);
}

module uim.platform.xyz.domain.ports.workpage_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.workpage;

interface WorkpageRepository
{
    Workpage[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Workpage* findById(WorkpageId id, TenantId tenantId);
    void save(Workpage page);
    void update(Workpage page);
    void remove(WorkpageId id, TenantId tenantId);
}

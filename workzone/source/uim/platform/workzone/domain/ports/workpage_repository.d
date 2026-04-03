module uim.platform.workzone.domain.ports.workpage_repository;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;

interface WorkpageRepository
{
    Workpage[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    Workpage* findById(WorkpageId id, TenantId tenantId);
    void save(Workpage page);
    void update(Workpage page);
    void remove(WorkpageId id, TenantId tenantId);
}

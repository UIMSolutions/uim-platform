module uim.platform.master_data_integration.domain.ports.change_log_repository;

import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.types;

/// Port: outgoing — change log persistence.
interface ChangeLogRepository
{
    ChangeLogEntry findById(ChangeLogEntryId id);
    ChangeLogEntry[] findByTenant(TenantId tenantId);
    ChangeLogEntry[] findByObjectId(TenantId tenantId, MasterDataObjectId objectId);
    ChangeLogEntry[] findByCategory(TenantId tenantId, MasterDataCategory category);
    ChangeLogEntry[] findSinceDeltaToken(TenantId tenantId, string deltaToken);
    ChangeLogEntry[] findSinceTimestamp(TenantId tenantId, long sinceTimestamp);
    void save(ChangeLogEntry entry);
    void remove(ChangeLogEntryId id);
}

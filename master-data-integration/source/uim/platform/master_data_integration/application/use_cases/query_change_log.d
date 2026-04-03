module application.usecases.query_change_log;

import uim.platform.xyz.application.dto;
import domain.entities.change_log_entry;
import domain.ports.change_log_repository;
import domain.types;

/// Application service for querying the change log (delta tracking).
class QueryChangeLogUseCase
{
    private ChangeLogRepository repo;

    this(ChangeLogRepository repo) { this.repo = repo; }

    ChangeLogEntry getEntry(ChangeLogEntryId id) { return repo.findById(id); }

    ChangeLogEntry[] query(ChangeLogQueryRequest req)
    {
        if (req.objectId.length > 0)
            return repo.findByObjectId(req.tenantId, req.objectId);
        if (req.deltaToken.length > 0)
            return repo.findSinceDeltaToken(req.tenantId, req.deltaToken);
        if (req.sinceTimestamp > 0)
            return repo.findSinceTimestamp(req.tenantId, req.sinceTimestamp);
        if (req.category.length > 0)
            return repo.findByCategory(req.tenantId, parseCategory(req.category));
        return repo.findByTenant(req.tenantId);
    }

    ChangeLogEntry[] listByTenant(TenantId tenantId) { return repo.findByTenant(tenantId); }
    ChangeLogEntry[] listByObjectId(TenantId tenantId, MasterDataObjectId objectId) { return repo.findByObjectId(tenantId, objectId); }
    ChangeLogEntry[] listSinceDeltaToken(TenantId tenantId, string deltaToken) { return repo.findSinceDeltaToken(tenantId, deltaToken); }

    private MasterDataCategory parseCategory(string s)
    {
        switch (s)
        {
            case "businessPartner": return MasterDataCategory.businessPartner;
            case "costCenter": return MasterDataCategory.costCenter;
            case "profitCenter": return MasterDataCategory.profitCenter;
            case "companyCode": return MasterDataCategory.companyCode;
            case "workforcePerson": return MasterDataCategory.workforcePerson;
            case "custom": return MasterDataCategory.custom;
            default: return MasterDataCategory.businessPartner;
        }
    }
}

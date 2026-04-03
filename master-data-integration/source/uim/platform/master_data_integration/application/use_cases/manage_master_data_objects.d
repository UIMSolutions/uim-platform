module uim.platform.master_data_integration.application.usecases.manage_master_data_objects;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.master_data_object;
import uim.platform.master_data_integration.domain.entities.change_log_entry;
import uim.platform.master_data_integration.domain.ports.master_data_object_repository;
import uim.platform.master_data_integration.domain.ports.change_log_repository;
import uim.platform.master_data_integration.domain.types;

/// Application service for master data object CRUD and lifecycle.
class ManageMasterDataObjectsUseCase
{
    private MasterDataObjectRepository repo;
    private ChangeLogRepository changeLogRepo;

    this(MasterDataObjectRepository repo, ChangeLogRepository changeLogRepo)
    {
        this.repo = repo;
        this.changeLogRepo = changeLogRepo;
    }

    CommandResult create(CreateMasterDataObjectRequest req)
    {
        if (req.objectType.length == 0)
            return CommandResult(false, "", "Object type is required");
        if (req.displayName.length == 0)
            return CommandResult(false, "", "Display name is required");

        import std.uuid : randomUUID;
        auto id = randomUUID().toString();

        MasterDataObject obj;
        obj.id = id;
        obj.tenantId = req.tenantId;
        obj.dataModelId = req.dataModelId;
        obj.category = parseCategory(req.category);
        obj.objectType = req.objectType;
        obj.displayName = req.displayName;
        obj.description = req.description;
        obj.status = RecordStatus.active;
        obj.localId = req.localId;
        obj.globalId = req.globalId.length > 0 ? req.globalId : id;
        obj.attributes = req.attributes;
        obj.sourceSystem = req.sourceSystem;
        obj.sourceClient = req.sourceClient;
        obj.currentVersion = randomUUID().toString();
        obj.versionNumber = 1;
        obj.createdBy = req.createdBy;
        obj.createdAt = clockSeconds();
        obj.modifiedAt = obj.createdAt;
        obj.modifiedBy = req.createdBy;

        repo.save(obj);
        logChange(req.tenantId, id, req.dataModelId, obj.category, ChangeType.create_,
            obj.objectType, [], (string[string]).init, req.attributes, req.sourceSystem, req.sourceClient, req.createdBy, 0, 1);
        return CommandResult(true, id, "");
    }

    CommandResult updateObject(MasterDataObjectId id, UpdateMasterDataObjectRequest req)
    {
        auto obj = repo.findById(id);
        if (obj.id.length == 0)
            return CommandResult(false, "", "Master data object not found");

        string[] changedFields;
        string[string] oldValues;

        if (req.displayName.length > 0 && req.displayName != obj.displayName)
        {
            oldValues["displayName"] = obj.displayName;
            obj.displayName = req.displayName;
            changedFields ~= "displayName";
        }
        if (req.description.length > 0 && req.description != obj.description)
        {
            oldValues["description"] = obj.description;
            obj.description = req.description;
            changedFields ~= "description";
        }
        if (req.status.length > 0)
        {
            oldValues["status"] = obj.status.stringof;
            obj.status = parseStatus(req.status);
            changedFields ~= "status";
        }
        foreach (k, v; req.attributes)
        {
            if (auto p = k in obj.attributes)
                oldValues[k] = *p;
            obj.attributes[k] = v;
            changedFields ~= k;
        }

        auto oldVersion = obj.versionNumber;
        obj.versionNumber++;

        import std.uuid : randomUUID;
        obj.currentVersion = randomUUID().toString();
        obj.modifiedAt = clockSeconds();
        obj.modifiedBy = req.modifiedBy;

        repo.update(obj);
        logChange(obj.tenantId, id, obj.dataModelId, obj.category, ChangeType.update_,
            obj.objectType, changedFields, oldValues, req.attributes, obj.sourceSystem, obj.sourceClient, req.modifiedBy, oldVersion, obj.versionNumber);
        return CommandResult(true, id, "");
    }

    MasterDataObject getObject(MasterDataObjectId id) { return repo.findById(id); }
    MasterDataObject[] listByTenant(TenantId tenantId) { return repo.findByTenant(tenantId); }
    MasterDataObject[] listByCategory(TenantId tenantId, string category) { return repo.findByCategory(tenantId, parseCategory(category)); }
    MasterDataObject[] listByDataModel(TenantId tenantId, DataModelId modelId) { return repo.findByDataModel(tenantId, modelId); }
    MasterDataObject findByGlobalId(TenantId tenantId, string globalId) { return repo.findByGlobalId(tenantId, globalId); }

    CommandResult deleteObject(MasterDataObjectId id)
    {
        auto obj = repo.findById(id);
        if (obj.id.length == 0)
            return CommandResult(false, "", "Master data object not found");

        repo.remove(id);
        logChange(obj.tenantId, id, obj.dataModelId, obj.category, ChangeType.delete_,
            obj.objectType, [], (string[string]).init, (string[string]).init, obj.sourceSystem, obj.sourceClient, "", obj.versionNumber, obj.versionNumber);
        return CommandResult(true, id, "");
    }

    private void logChange(TenantId tenantId, MasterDataObjectId objectId, DataModelId dataModelId,
        MasterDataCategory category, ChangeType changeType, string objectType,
        string[] changedFields, string[string] oldValues, string[string] newValues,
        string sourceSystem, string sourceClient, string changedBy, long fromVersion, long toVersion)
    {
        import std.uuid : randomUUID;
        ChangeLogEntry entry;
        entry.id = randomUUID().toString();
        entry.tenantId = tenantId;
        entry.objectId = objectId;
        entry.dataModelId = dataModelId;
        entry.category = category;
        entry.changeType = changeType;
        entry.objectType = objectType;
        entry.changedFields = changedFields;
        entry.oldValues = oldValues;
        entry.newValues = newValues;
        entry.sourceSystem = sourceSystem;
        entry.sourceClient = sourceClient;
        entry.changedBy = changedBy;
        entry.fromVersion = fromVersion;
        entry.toVersion = toVersion;
        entry.deltaToken = entry.id;
        entry.timestamp = clockSeconds();
        changeLogRepo.save(entry);
    }

    private MasterDataCategory parseCategory(string s)
    {
        switch (s)
        {
            case "businessPartner": return MasterDataCategory.businessPartner;
            case "costCenter": return MasterDataCategory.costCenter;
            case "profitCenter": return MasterDataCategory.profitCenter;
            case "companyCode": return MasterDataCategory.companyCode;
            case "workforcePerson": return MasterDataCategory.workforcePerson;
            case "bankAccount": return MasterDataCategory.bankAccount;
            case "plant": return MasterDataCategory.plant;
            case "purchasingOrganization": return MasterDataCategory.purchasingOrganization;
            case "salesOrganization": return MasterDataCategory.salesOrganization;
            case "customerMaterial": return MasterDataCategory.customerMaterial;
            case "supplierMaterial": return MasterDataCategory.supplierMaterial;
            case "custom": return MasterDataCategory.custom;
            default: return MasterDataCategory.businessPartner;
        }
    }

    private RecordStatus parseStatus(string s)
    {
        switch (s)
        {
            case "active": return RecordStatus.active;
            case "inactive": return RecordStatus.inactive;
            case "blocked": return RecordStatus.blocked;
            case "markedForDeletion": return RecordStatus.markedForDeletion;
            default: return RecordStatus.active;
        }
    }
}

private long clockSeconds()
{
    import core.time : MonoTime;
    return MonoTime.currTime.ticks / 10_000_000;
}

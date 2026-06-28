/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.master_data_object;

// import uim.platform.master_data_integration.domain.entities.master_data_object;
// import uim.platform.master_data_integration.domain.entities.change_log_entry;
// import uim.platform.master_data_integration.domain.ports.repositories.master_data_objects;
import uim.platform.master_data_integration.application.usecases;


import uim.platform.master_data_integration;

mixin(ShowModule!());

@safe:
/// Application service for master data object CRUD and lifecycle.
class ManageMasterDataObjectsUseCase { // TODO: UIMUseCase {
  private MasterDataObjectRepository repo;
  private ChangeLogRepository changeLogRepo;

  this(MasterDataObjectRepository repo, ChangeLogRepository changeLogRepo) {
    this.repo = repo;
    this.changeLogRepo = changeLogRepo;
  }

  CommandResult createObject(CreateMasterDataObjectRequest req) {
    if (req.objectType.length == 0)
      return CommandResult(false, "", "Object type is required");
    if (req.displayName.length == 0)
      return CommandResult(false, "", "Display name is required");

    MasterDataObject obj;
    obj.initEntity(req.tenantId, req.createdBy);

    obj.modelId = req.modelId;
    obj.category = toMasterDataCategory(req.category);
    obj.objectType = req.objectType;
    obj.displayName = req.displayName;
    obj.description = req.description;
    obj.status = RecordStatus.active;
    obj.localId = req.localId;
    obj.globalId = req.globalId.length > 0 ? req.globalId : obj.id.value;
    obj.attributes = req.attributes;
    obj.sourceSystem = req.sourceSystem;
    obj.sourceClient = req.sourceClient;
    obj.currentVersion = randomUUID();
    obj.versionNumber = 1;

    repo.save(obj);
    // ToDo: logChange(req.tenantId, obj.id, req.modelId, obj.category,
    //   ChangeType.create_, obj.objectType, [], (string[string]).init,
    //   req.attributes, req.sourceSystem, req.sourceClient, req.createdBy, 0, 1);
    return CommandResult(true, obj.id.value, "");
  }

  CommandResult updateObject(UpdateMasterDataObjectRequest req) {
    auto obj = repo.findById(req.tenantId, req.objectId);
    if (obj.isNull)
      return CommandResult(false, "", "Master data object not found");

    string[] changedFields;
    string[string] oldValues;

    if (req.displayName.length > 0 && req.displayName != obj.displayName) {
      oldValues["displayName"] = obj.displayName;
      obj.displayName = req.displayName;
      changedFields ~= "displayName";
    }
    if (req.description.length > 0 && req.description != obj.description) {
      oldValues["description"] = obj.description;
      obj.description = req.description;
      changedFields ~= "description";
    }
    if (req.status.length > 0) {
      // Todo:
      // oldValues["status"] = obj.status.to!string;
      // obj.status = toMasterDataObjectStatus(req.status);
      // changedFields ~= "status";
    }
    foreach (k, v; req.attributes) {
      if (auto p = k in obj.attributes)
        oldValues[k] = *p;
      obj.attributes[k] = v;
      changedFields ~= k;
    }

    auto oldVersion = obj.versionNumber;
    obj.versionNumber++;

    obj.currentVersion = randomUUID();
    obj.updatedAt = clockSeconds();
    obj.updatedBy = req.updatedBy;

    repo.update(obj);
    // ToDo: logChange(obj.tenantId, obj.id, obj.modelId, obj.category, ChangeType.update_,
    //   obj.objectType, changedFields, oldValues, req.attributes, obj.sourceSystem,
    //   obj.sourceClient, req.updatedBy, oldVersion, obj.versionNumber);
    return CommandResult(true, obj.id.value, "");
  }

  MasterDataObject getObject(TenantId tenantId, MasterDataObjectId id) {
    return repo.findById(tenantId, id);
  }

  MasterDataObject[] listObjects(TenantId tenantId) {
    return repo.find(tenantId);
  }

  MasterDataObject[] listObjects(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, toMasterDataCategory(category));
  }

  MasterDataObject[] listObjects(TenantId tenantId, DataModelId modelId) {
    return repo.findByDataModel(tenantId, modelId);
  }

  MasterDataObject findObject(TenantId tenantId, string globalId) {
    return repo.findByGlobal(tenantId, globalId);
  }

  CommandResult deleteObject(TenantId tenantId, MasterDataObjectId id) {
    auto obj = repo.findById(tenantId, id);
    if (obj.isNull)
      return CommandResult(false, "", "Master data object not found");

    repo.remove(obj);
    logChange(obj.tenantId, obj.id, obj.modelId, obj.category,
      ChangeType.delete_, obj.objectType, [], (string[string]).init,
      (string[string]).init, obj.sourceSystem, obj.sourceClient, "",
      obj.versionNumber, obj.versionNumber);
    return CommandResult(true, obj.id.value, "");
  }

  private void logChange(TenantId tenantId, MasterDataObjectId objectId,
    DataModelId modelId, MasterDataCategory category,
    ChangeType changeType,
    string objectType,
    string[] changedFields,
    string[string] oldValues,
    string[string] newValues,
    string sourceSystem, string sourceClient, string changedBy, long fromVersion, long toVersion) {

    ChangeLogEntry entry;
    entry.initEntity(tenantId);

    entry.objectId = objectId;
    entry.modelId = modelId;
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
    entry.deltaToken = entry.id.value;
    entry.timestamp = entry.createdAt;

    changeLogRepo.save(entry);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.data_models;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.data_model;
import uim.platform.master_data_integration.domain.ports.data_model_repository;
import uim.platform.master_data_integration.domain.types;

/// Application service for data model / schema management.
class ManageDataModelsUseCase
{
  private DataModelRepository repo;

  this(DataModelRepository repo)
  {
    this.repo = repo;
  }

  CommandResult create(CreateDataModelRequest req)
  {
    if (req.name.length == 0)
      return CommandResult(false, "", "Data model name is required");
    if (req.namespace.length == 0)
      return CommandResult(false, "", "Namespace is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    DataModel model;
    model.id = id;
    model.tenantId = req.tenantId;
    model.name = req.name;
    model.namespace = req.namespace;
    model.version_ = req.version_.length > 0 ? req.version_ : "1.0.0";
    model.description = req.description;
    model.category = parseCategory(req.category);
    model.fields = toFieldDefs(req.fields);
    model.keyFields = req.keyFields;
    model.requiredFields = req.requiredFields;
    model.isActive = true;
    model.createdBy = req.createdBy;
    model.createdAt = clockSeconds();
    model.modifiedAt = model.createdAt;

    repo.save(model);
    return CommandResult(true, id, "");
  }

  CommandResult updateModel(DataModelId id, UpdateDataModelRequest req)
  {
    auto model = repo.findById(id);
    if (model.id.length == 0)
      return CommandResult(false, "", "Data model not found");

    if (req.description.length > 0)
      model.description = req.description;
    if (req.version_.length > 0)
      model.version_ = req.version_;
    if (req.fields.length > 0)
      model.fields = toFieldDefs(req.fields);
    if (req.keyFields.length > 0)
      model.keyFields = req.keyFields;
    if (req.requiredFields.length > 0)
      model.requiredFields = req.requiredFields;
    model.modifiedAt = clockSeconds();

    repo.update(model);
    return CommandResult(true, id, "");
  }

  DataModel getModel(DataModelId id)
  {
    return repo.findById(id);
  }

  DataModel[] listByTenant(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  DataModel[] listByCategory(TenantId tenantId, string category)
  {
    return repo.findByCategory(tenantId, parseCategory(category));
  }

  DataModel findByName(TenantId tenantId, string name)
  {
    return repo.findByName(tenantId, name);
  }

  CommandResult deleteModel(DataModelId id)
  {
    auto model = repo.findById(id);
    if (model.id.length == 0)
      return CommandResult(false, "", "Data model not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private FieldDefinition[] toFieldDefs(FieldDefinitionDto[] dtos)
  {
    FieldDefinition[] result;
    foreach (ref dto; dtos)
    {
      FieldDefinition fd;
      fd.name = dto.name;
      fd.displayName = dto.displayName;
      fd.type_ = parseFieldType(dto.type_);
      fd.isRequired = dto.isRequired;
      fd.isKey = dto.isKey;
      fd.defaultValue = dto.defaultValue;
      fd.maxLength = dto.maxLength;
      fd.referenceModel = dto.referenceModel;
      fd.description = dto.description;
      result ~= fd;
    }
    return result;
  }

  private FieldType parseFieldType(string s)
  {
    switch (s)
    {
    case "string":
      return FieldType.string_;
    case "integer":
      return FieldType.integer_;
    case "decimal":
      return FieldType.decimal_;
    case "boolean":
      return FieldType.boolean_;
    case "date":
      return FieldType.date;
    case "timestamp":
      return FieldType.timestamp;
    case "reference":
      return FieldType.reference;
    case "array":
      return FieldType.array_;
    case "object":
      return FieldType.object_;
    default:
      return FieldType.string_;
    }
  }

  private MasterDataCategory parseCategory(string s)
  {
    switch (s)
    {
    case "businessPartner":
      return MasterDataCategory.businessPartner;
    case "costCenter":
      return MasterDataCategory.costCenter;
    case "profitCenter":
      return MasterDataCategory.profitCenter;
    case "companyCode":
      return MasterDataCategory.companyCode;
    case "workforcePerson":
      return MasterDataCategory.workforcePerson;
    case "bankAccount":
      return MasterDataCategory.bankAccount;
    case "plant":
      return MasterDataCategory.plant;
    case "custom":
      return MasterDataCategory.custom;
    default:
      return MasterDataCategory.businessPartner;
    }
  }
}

private long clockSeconds()
{
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}

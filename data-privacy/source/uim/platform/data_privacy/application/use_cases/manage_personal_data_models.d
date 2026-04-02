module application.usecases.manage_personal_data_models;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.personal_data_model;
import domain.ports.personal_data_model_repository;
import application.dto;

class ManagePersonalDataModelsUseCase
{
    private PersonalDataModelRepository repo;

    this(PersonalDataModelRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createModel(CreatePersonalDataModelRequest req)
    {
        if (req.tenantId.length == 0)
            return CommandResult("", "Tenant ID is required");
        if (req.fieldName.length == 0)
            return CommandResult("", "Field name is required");
        if (req.sourceSystem.length == 0)
            return CommandResult("", "Source system is required");

        auto now = Clock.currStdTime();
        auto model = PersonalDataModel();
        model.id = randomUUID().toString();
        model.tenantId = req.tenantId;
        model.fieldName = req.fieldName;
        model.fieldDescription = req.fieldDescription;
        model.category = req.category;
        model.sensitivity = req.sensitivity;
        model.sourceSystem = req.sourceSystem;
        model.sourceEntity = req.sourceEntity;
        model.subjectType = req.subjectType;
        model.isSpecialCategory = req.isSpecialCategory;
        model.legalReference = req.legalReference;
        model.createdAt = now;
        model.updatedAt = now;

        repo.save(model);
        return CommandResult(model.id, "");
    }

    PersonalDataModel* getModel(PersonalDataModelId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    PersonalDataModel[] listModels(TenantId tenantId)
    {
        return repo.findByTenant(tenantId);
    }

    PersonalDataModel[] listByCategory(TenantId tenantId, PersonalDataCategory category)
    {
        return repo.findByCategory(tenantId, category);
    }

    PersonalDataModel[] listSpecialCategories(TenantId tenantId)
    {
        return repo.findSpecialCategories(tenantId);
    }

    CommandResult updateModel(UpdatePersonalDataModelRequest req)
    {
        auto model = repo.findById(req.id, req.tenantId);
        if (model is null)
            return CommandResult("", "Personal data model not found");

        if (req.fieldName.length > 0) model.fieldName = req.fieldName;
        if (req.fieldDescription.length > 0) model.fieldDescription = req.fieldDescription;
        model.category = req.category;
        model.sensitivity = req.sensitivity;
        if (req.sourceSystem.length > 0) model.sourceSystem = req.sourceSystem;
        if (req.sourceEntity.length > 0) model.sourceEntity = req.sourceEntity;
        model.isSpecialCategory = req.isSpecialCategory;
        if (req.legalReference.length > 0) model.legalReference = req.legalReference;
        model.updatedAt = Clock.currStdTime();

        repo.update(*model);
        return CommandResult(model.id, "");
    }

    void deleteModel(PersonalDataModelId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}

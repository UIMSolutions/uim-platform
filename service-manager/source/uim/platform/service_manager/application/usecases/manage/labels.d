/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageLabelsUseCase {
    private ILabelRepository repo;

    this(ILabelRepository repo) {
        this.repo = repo;
    }

    Label[] listLabels(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Label getLabel(TenantId tenantId, LabelId id) {
        return repo.findById(tenantId, id);
    }

    Label[] listLabels(TenantId tenantId, string resourceType, string resourceId) {
        return repo.findByResource(tenantId, resourceType, resourceId);
    }

    UsecaseResult createLabel(CreateLabelRequest dto) {
        Label e;
        e.id = LabelId(currentTimestamp.to!string);
        e.tenantId = dto.tenantId;
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.key = dto.key;
        e.value = dto.value;
        e.createdAt = currentTimestamp;

        if (dto.key.length == 0)
            return UsecaseResult(false, "", "Label key is required");

        repo.save(e);
        return UsecaseResult(true, e.id.value, "");
    }

    UsecaseResult updateLabel(UpdateLabelRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.labelId);
        if (existing.isNull)
            return UsecaseResult(false, "", "Label not found");

        if (dto.key.length > 0)
            existing.key = dto.key;
        if (dto.value.length > 0)
            existing.value = dto.value;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteLabel(TenantId tenantId, LabelId id) {
        auto label = repo.findById(tenantId, id);
        if (label.isNull)
            return UsecaseResult(false, "", "Label not found");

        repo.remove(label);
        return UsecaseResult(true, label.id.value, "");
    }
}

///
unittest {
    auto repo = new LabelRepository();
    auto usecase = new ManageLabelsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateLabelRequest createDto;
    createDto.tenantId = tenantId;
    createDto.labelId = LabelId("label-1");
    // TODO: createDto.name = "Test Label";
    auto createResult = usecase.createLabel(createDto);
    // TODO: assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listLabels(tenantId);
    // TODO: assert(items.length == 1);

    // Test get
    auto item = usecase.getLabel(tenantId, LabelId("label-1"));
    // TODO: assert(!item.isNull);

    // Test update
    UpdateLabelRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.labelId = LabelId("label-1");
    // TODO: updateDto.name = "Updated Label";
    auto updateResult = usecase.updateLabel(updateDto);
    // TODO: assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteLabel(tenantId, LabelId("label-1"));
    // TODO: assert(deleteResult.success, deleteResult.message);
    // TODO: assert(usecase.listLabels(tenantId).length == 0);

}

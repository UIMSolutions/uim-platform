module uim.platform.service_manager.application.usecases.manage.labels;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageLabelsUseCase { // TODO: UIMUseCase {
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

    CommandResult createLabel(CreateLabelRequest dto) {
        Label e;
        e.id = LabelId(currentTimestamp.to!string);
        e.tenantId = dto.tenantId;
        e.resourceId = dto.resourceId;
        e.resourceType = dto.resourceType;
        e.key = dto.key;
        e.value = dto.value;
        e.createdAt = currentTimestamp;

        if (dto.key.length == 0)
            return CommandResult(false, "", "Label key is required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateLabel(UpdateLabelRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.labelId);
        if (existing.isNull)
            return CommandResult(false, "", "Label not found");

        if (dto.key.length > 0)
            existing.key = dto.key;
        if (dto.value.length > 0)
            existing.value = dto.value;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteLabel(TenantId tenantId, LabelId id) {
        auto label = repo.findById(tenantId, id);
        if (label.isNull)
            return CommandResult(false, "", "Label not found");

        repo.remove(label);
        return CommandResult(true, label.id.value, "");
    }
}

///
unittest {
    auto repo = new ILabelRepository();
    auto usecase = new ManageLabelsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateLabelRequest createDto;
    createDto.tenantId = tenantId;
    createDto.labelId = LabelId("label-1");
    createDto.name = "Test Label";
    auto createResult = usecase.createLabel(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listLabels(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getLabel(tenantId, LabelId("label-1"));
    assert(!item.isNull);

    // Test update
    UpdateLabelRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.labelId = LabelId("label-1");
    updateDto.name = "Updated Label";
    auto updateResult = usecase.updateLabel(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteLabel(tenantId, LabelId("label-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listLabels(tenantId).length == 0);

}

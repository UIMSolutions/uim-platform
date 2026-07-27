module uim.platform.service_manager.application.usecases.manage.service_plans;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManageServicePlansUseCase { // TODO: UIMUseCase {
    private IServicePlanRepository repo;

    this(IServicePlanRepository repo) {
        this.repo = repo;
    }

    ServicePlan[] listPlans(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServicePlan getPlan(TenantId tenantId, ServicePlanId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult createPlan(CreateServicePlanRequest dto) {
        auto plan = ServicePlan(dto.tenantId);

        plan.id = ServicePlanId(currentTimestamp.to!string);
        plan.tenantId = dto.tenantId;
        plan.name = dto.name;
        plan.description = dto.description;
        plan.catalogName = dto.catalogName;
        plan.offeringId = dto.offeringId;
        plan.maxInstances = dto.maxInstances;
        plan.schemas = dto.schemas;
        plan.metadata = dto.metadata;
        plan.createdAt = currentTimestamp;
        plan.updatedAt = plan.createdAt;

        if (dto.name.isEmpty)
            return CommandResult(false, "", "Service plan name is required");

        repo.save(plan);
        return CommandResult(true, plan.id.value, "");
    }

    CommandResult updatePlan(UpdateServicePlanRequest dto) {
        auto existing = repo.findById(dto.tenantId, dto.planId);
        if (existing.isNull)
            return CommandResult(false, "", "Service plan not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.metadata.length > 0) existing.metadata = dto.metadata;
        if (dto.schemas.length > 0) existing.schemas = dto.schemas;
        existing.maxInstances = dto.maxInstances;
        existing.updatedAt = currentTimestamp;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deletePlan(TenantId tenantId, ServicePlanId id) {
        auto plan = repo.findById(tenantId, id);
        if (plan.isNull)
            return CommandResult(false, "", "Service plan not found");

        repo.remove(plan);
        return CommandResult(true, plan.id.value, "");
    }
}

///
unittest {
    auto repo = new IServicePlanRepository();
    auto usecase = new ManageServicePlansUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    CreateServicePlanRequest createDto;
    createDto.tenantId = tenantId;
    createDto.servicePlanId = ServicePlanId("servicePlan-1");
    createDto.name = "Test ServicePlan";
    auto createResult = usecase.createPlan(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listPlans(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getPlan(tenantId, ServicePlanId("servicePlan-1"));
    assert(!item.isNull);

    // Test update
    UpdateServicePlanRequest updateDto;
    updateDto.tenantId = tenantId;
    updateDto.servicePlanId = ServicePlanId("servicePlan-1");
    updateDto.name = "Updated ServicePlan";
    auto updateResult = usecase.updatePlan(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deletePlan(tenantId, ServicePlanId("servicePlan-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listPlans(tenantId).length == 0);

}

module uim.platform.data_retention.application.usecases.manage.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageApplicationGroupsUseCase { // TODO: UIMUseCase {
    private ApplicationGroupRepository appGroupRepository;

    this(ApplicationGroupRepository appGroupRepository) {
        this.appGroupRepository = appGroupRepository;
    }

    CommandResult createApplicationGroup(CreateApplicationGroupRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return CommandResult(false, "", "Application group name is required");

        ApplicationGroup ag;
        ag.id = ApplicationGroupId(randomUUID().toString());
        ag.tenantId = req.tenantId;
        ag.name = req.name;
        ag.description = req.description;
        ag.scope_ = toApplicationGroupScope(req.scope_);
        ag.applicationIds = req.applicationIds;
        ag.isActive = true;
        ag.createdBy = req.createdBy;
        ag.createdAt = clockSeconds();

        appGroupRepository.save(ag);
        return CommandResult(true, ag.id.value, "");
    }

    CommandResult updateApplicationGroup(UpdateApplicationGroupRequest req) {
        auto ag = appGroupRepository.findById(req.tenantId, req.groupId);
        if (ag.isNull)
            return CommandResult(false, "", "Application group not found");

        if (req.name.length > 0)
            ag.name = req.name;
        if (req.description.length > 0)
            ag.description = req.description;
        if (req.scope_.length > 0)
            ag.scope_ = toApplicationGroupScope(req.scope_);
        if (req.applicationIds.length > 0)
            ag.applicationIds = req.applicationIds;
        ag.isActive = req.isActive;
        ag.updatedAt = clockSeconds();

        appGroupRepository.update(ag);
        return CommandResult(true, ag.id.value, "");
    }

    bool hasApplicationGroup(TenantId tenantId, ApplicationGroupId id) {
        return appGroupRepository.existsById(tenantId, id);
    }

    ApplicationGroup getApplicationGroup(TenantId tenantId, ApplicationGroupId id) {
        return appGroupRepository.findById(tenantId, id);
    }

    ApplicationGroup[] listApplicationGroups(TenantId tenantId) {
        return appGroupRepository.findAll(tenantId);
    }

    CommandResult deleteApplicationGroup(TenantId tenantId, ApplicationGroupId id) {
        auto group = appGroupRepository.findById(tenantId, id);
        if (group.isNull)
            return CommandResult(false, "", "Application group not found");

        appGroupRepository.remove(group);
        return CommandResult(true, group.id.value, "");
    }

}

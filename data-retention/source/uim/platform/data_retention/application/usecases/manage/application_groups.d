module uim.platform.data_retention.application.usecases.manage.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageApplicationGroupsUseCase { // TODO: UIMUseCase {
    private ApplicationGroupRepository appGroupRepository;

    this(ApplicationGroupRepository appGroupRepository) {
        this.appGroupRepository = appGroupRepository;
    }

    CommandResult create(CreateApplicationGroupRequest req) {
        import std.uuid : randomUUID;

        if (req.name.length == 0)
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

    CommandResult updateAppGroup(string id, UpdateApplicationGroupRequest req) {
        return updateAppGroup(ApplicationGroupId(id), req);
    }

    CommandResult updateAppGroup(ApplicationGroupId id, UpdateApplicationGroupRequest req) {
        if (!appGroupRepository.existsById(id))
            return CommandResult(false, "", "Application group not found");

        auto ag = appGroupRepository.findById(id);
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
        return CommandResult(true, id.value, "");
    }

    bool hasAppGroup(string id) {
        return hasAppGroup(ApplicationGroupId(id));
    }

    bool hasAppGroup(ApplicationGroupId id) {
        return appGroupRepository.existsById(id);
    }

    ApplicationGroup getAppGroupById(string id) {
        return getAppGroupById(ApplicationGroupId(id));
    }

    ApplicationGroup getAppGroupById(ApplicationGroupId id) {
        return appGroupRepository.findById(id);
    }

    ApplicationGroup[] list(TenantId tenantId) {
        return list(TenantId(tenantId));
    }

    ApplicationGroup[] list(TenantId tenantId) {
        return appGroupRepository.findAll(tenantId);
    }

    CommandResult removeAppGroup(string id) {
        return removeAppGroup(ApplicationGroupId(id));
    }

    CommandResult removeAppGroup(ApplicationGroupId id) {
        appGroupRepository.removeById(id);
        return CommandResult(true, id.value, "");
    }

}

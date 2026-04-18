module uim.platform.data_retention.application.usecases.manage.application_groups;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageApplicationGroupsUseCase : UIMUseCase {
    private ApplicationGroupRepository repo;

    this(ApplicationGroupRepository repo) { this.repo = repo; }

    CommandResult create(CreateApplicationGroupRequest req) {
        import std.uuid : randomUUID;
        if (req.name.length == 0) return CommandResult(false, "", "Application group name is required");

        ApplicationGroup ag;
        ag.id = ApplicationGroupId(randomUUID().toString());
        ag.tenantId = req.tenantId;
        ag.name = req.name;
        ag.description = req.description;
        ag.scope_ = parseScope(req.scope_);
        ag.applicationIds = req.applicationIds;
        ag.isActive = true;
        ag.createdBy = req.createdBy;
        ag.createdAt = clockSeconds();

        repo.save(ag);
        return CommandResult(true, ag.id.value, "");
    }

    CommandResult update(string id, UpdateApplicationGroupRequest req) { return update(ApplicationGroupId(id), req); }

    CommandResult update(ApplicationGroupId id, UpdateApplicationGroupRequest req) {
        if (!repo.existsById(id)) return CommandResult(false, "", "Application group not found");

        auto ag = repo.findById(id);
        if (req.name.length > 0) ag.name = req.name;
        if (req.description.length > 0) ag.description = req.description;
        if (req.scope_.length > 0) ag.scope_ = parseScope(req.scope_);
        if (req.applicationIds.length > 0) ag.applicationIds = req.applicationIds;
        ag.isActive = req.isActive;
        ag.updatedAt = clockSeconds();

        repo.update(ag);
        return CommandResult(true, id.value, "");
    }

    bool hasById(string id) { return hasById(ApplicationGroupId(id)); }
    bool hasById(ApplicationGroupId id) { return repo.existsById(id); }
    ApplicationGroup getById(string id) { return getById(ApplicationGroupId(id)); }
    ApplicationGroup getById(ApplicationGroupId id) { return repo.findById(id); }
    ApplicationGroup[] list(string tenantId) { return list(TenantId(tenantId)); }
    ApplicationGroup[] list(TenantId tenantId) { return repo.findAll(tenantId); }
    CommandResult remove(string id) { return remove(ApplicationGroupId(id)); }
    CommandResult remove(ApplicationGroupId id) { repo.remove(id); return CommandResult(true, id.value, ""); }

    private static ApplicationGroupScope parseScope(string s) {
        switch (s) {
            case "global": return ApplicationGroupScope.global;
            case "regional": return ApplicationGroupScope.regional;
            case "local": return ApplicationGroupScope.local;
            default: return ApplicationGroupScope.global;
        }
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.user_task_filters;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageUserTaskFiltersUseCase { // TODO: UIMUseCase {
    private UserTaskFilterRepository repo;

    this(UserTaskFilterRepository repo) {
        this.repo = repo;
    }

    UserTaskFilter getById(TenantId tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    UserTaskFilter[] listByUser(TenantId tenantId, string userId) {
        return repo.findByUser(tenantId, userId);
    }

    UserTaskFilter getDefault(TenantId tenantId, string userId) {
        return repo.findDefault(tenantId, userId);
    }

    CommandResult create(CreateUserTaskFilterRequest req) {
        UserTaskFilter f;
        f.id = req.id;
        f.tenantId = req.tenantId;
        f.userId = req.userId;
        f.name = req.name;
        f.description = req.description;
        f.isDefault = req.isDefault;
        repo.save(req.tenantId, f);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult update(UpdateUserTaskFilterRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing == UserTaskFilter.init)
            return CommandResult(false, "", "Filter not found");
        if (req.name.length > 0) existing.name = req.name;
        if (req.description.length > 0) existing.description = req.description;
        existing.isDefault = req.isDefault;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult setDefault(TenantId tenantId, string id) {
        auto f = repo.findById(tenantId, id);
        if (f == UserTaskFilter.init)
            return CommandResult(false, "", "Filter not found");
        f.isDefault = true;
        repo.update(tenantId, f);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, string id) {
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

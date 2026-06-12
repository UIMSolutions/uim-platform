/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.user_task_filters;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageUserTaskFiltersUseCase { // TODO: UIMUseCase {
    private UserTaskFilterRepository repo;

    this(UserTaskFilterRepository repo) {
        this.repo = repo;
    }

    UserTaskFilter getFilterById(TenantId tenantId, UserTaskFilterId id) {
        return repo.findById(tenantId, id);
    }

    UserTaskFilter[] listFiltersByUser(TenantId tenantId, UserId userId) {
        return repo.findByUser(tenantId, userId);
    }

    UserTaskFilter getDefaultFilter(TenantId tenantId, UserId userId) {
        return repo.findDefault(tenantId, userId);
    }

    CommandResult createFilter(CreateUserTaskFilterRequest req) {
        auto taskFilter = UserTaskFilter(req.tenantId);
        taskFilter.id = req.filterId;
        taskFilter.userId = req.userId;
        taskFilter.name = req.name;
        taskFilter.description = req.description;
        taskFilter.isDefault = req.isDefault;

        repo.save(taskFilter);
        return CommandResult(true, taskFilter.id.value, "");
    }

    CommandResult updateFilter(UpdateUserTaskFilterRequest req) {
        auto taskFilter = repo.findById(req.tenantId, req.id);
        if (taskFilter.isNull)
            return CommandResult(false, "", "Filter not found");
            
        if (req.name.length > 0) taskFilter.name = req.name;
        if (req.description.length > 0) taskFilter.description = req.description;
        taskFilter.isDefault = req.isDefault;

        repo.update(taskFilter);
        return CommandResult(true, taskFilter.id.value, "");
    }

    CommandResult setDefaultFilter(TenantId tenantId, UserTaskFilterId id) {
        auto taskFilter = repo.findById(tenantId, id);
        if (taskFilter.isNull)
            return CommandResult(false, "", "Filter not found");
        taskFilter.isDefault = true;
        
        repo.update(taskFilter);
        return CommandResult(true, taskFilter.id.value, "");
    }

    CommandResult deleteFilter(TenantId tenantId, UserTaskFilterId id) {
        auto taskFilter = repo.findById(tenantId, id);
        if (taskFilter.isNull)
            return CommandResult(false, "", "Filter not found");

        repo.remove(taskFilter);
        return CommandResult(true, taskFilter.id.value, "");
    }
}

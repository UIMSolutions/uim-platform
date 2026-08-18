/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.user_task_filters;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageUserTaskFiltersUseCase {
    private IUserTaskFilterRepository repo;

    this(IUserTaskFilterRepository repo) {
        this.repo = repo;
    }

    UserTaskFilter getFilter(TenantId tenantId, UserTaskFilterId id) {
        return repo.findById(tenantId, id);
    }

    UserTaskFilter[] listFilters(TenantId tenantId, UserId userId) {
        return repo.findByUser(tenantId, userId);
    }

    // UserTaskFilter getDefaultFilter(TenantId tenantId, UserId userId) {
    //     return repo.findDefault(tenantId, userId);
    // }

    UsecaseResult createFilter(CreateUserTaskFilterRequest req) {
        auto taskFilter = UserTaskFilter(req.tenantId);
        taskFilter.id = req.filterId;
        // taskFilter.userId = req.userId;
        taskFilter.name = req.name;
        taskFilter.description = req.description;
        taskFilter.isDefault = req.isDefault;

        repo.save(taskFilter);
        return UsecaseResult(true, taskFilter.id.value, "");
    }

    UsecaseResult updateFilter(UpdateUserTaskFilterRequest req) {
        auto taskFilter = repo.findById(req.tenantId, req.filterId);
        if (taskFilter.isNull)
            return UsecaseResult(false, "", "Filter not found");

        if (req.name.length > 0) taskFilter.name = req.name;
        if (req.description.length > 0) taskFilter.description = req.description;
        taskFilter.isDefault = req.isDefault;

        repo.update(taskFilter);
        return UsecaseResult(true, taskFilter.id.value, "");
    }

    UsecaseResult setDefaultFilter(TenantId tenantId, UserTaskFilterId id) {
        auto taskFilter = repo.findById(tenantId, id);
        if (taskFilter.isNull)
            return UsecaseResult(false, "", "Filter not found");
        taskFilter.isDefault = true;
        
        repo.update(taskFilter);
        return UsecaseResult(true, taskFilter.id.value, "");
    }

    UsecaseResult deleteFilter(TenantId tenantId, UserTaskFilterId id) {
        auto taskFilter = repo.findById(tenantId, id);
        if (taskFilter.isNull)
            return UsecaseResult(false, "", "Filter not found");

        repo.remove(taskFilter);
        return UsecaseResult(true, taskFilter.id.value, "");
    }
}

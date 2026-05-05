/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.manage.task_providers;

import uim.platform.task_center;

mixin(ShowModule!());

@safe:

class ManageTaskProvidersUseCase { // TODO: UIMUseCase {
    private TaskProviderRepository repo;

    this(TaskProviderRepository repo) {
        this.repo = repo;
    }

    TaskProvider getById(TenantId tenantId, string id) {
        return repo.findById(tenantId, id);
    }

    TaskProvider[] list(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    TaskProvider[] listByStatus(TenantId tenantId, ProviderStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    TaskProvider[] listByType(TenantId tenantId, ProviderType ptype) {
        return repo.findByType(tenantId, ptype);
    }

    CommandResult create(CreateTaskProviderRequest req) {
        TaskProvider p;
        p.id = req.id;
        p.tenantId = req.tenantId;
        p.name = req.name;
        p.description = req.description;
        p.endpointUrl = req.endpointUrl;
        p.authEndpointUrl = req.authEndpointUrl;
        p.clientId = req.clientId;
        p.createdBy = req.createdBy;
        repo.save(req.tenantId, p);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult update(UpdateTaskProviderRequest req) {
        auto existing = repo.findById(req.tenantId, req.id);
        if (existing == TaskProvider.init)
            return CommandResult(false, "", "Provider not found");
        if (req.name.length > 0) existing.name = req.name;
        if (req.description.length > 0) existing.description = req.description;
        if (req.endpointUrl.length > 0) existing.endpointUrl = req.endpointUrl;
        if (req.authEndpointUrl.length > 0) existing.authEndpointUrl = req.authEndpointUrl;
        if (req.clientId.length > 0) existing.clientId = req.clientId;
        existing.updatedBy = req.updatedBy;
        repo.update(req.tenantId, existing);
        return CommandResult(true, req.id.value, "");
    }

    CommandResult activate(TenantId tenantId, string id) {
        auto p = repo.findById(tenantId, id);
        if (p == TaskProvider.init)
            return CommandResult(false, "", "Provider not found");
        p.status = ProviderStatus.active;
        repo.update(tenantId, p);
        return CommandResult(true, id.value, "");
    }

    CommandResult deactivate(TenantId tenantId, string id) {
        auto p = repo.findById(tenantId, id);
        if (p == TaskProvider.init)
            return CommandResult(false, "", "Provider not found");
        p.status = ProviderStatus.inactive;
        repo.update(tenantId, p);
        return CommandResult(true, id.value, "");
    }

    CommandResult sync(TenantId tenantId, string id) {
        auto p = repo.findById(tenantId, id);
        if (p == TaskProvider.init)
            return CommandResult(false, "", "Provider not found");
        p.status = ProviderStatus.syncing;
        repo.update(tenantId, p);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(TenantId tenantId, string id) {
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

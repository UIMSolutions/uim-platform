/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.task_center.application.usecases.manage.task_providers;

import uim.platform.task_center;

// mixin(ShowModule!());

@safe:

class ManageTaskProvidersUseCase { // TODO: UIMUseCase {
    private TaskProviderRepository repo;

    this(TaskProviderRepository repo) {
        this.repo = repo;
    }

    TaskProvider getById(TenantId tenantId, TaskProviderId id) {
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

    CommandResult createTaskProvider(CreateTaskProviderRequest req) {
        TaskProvider p;
        p.initEntity(req.tenantId, req.createdBy);

        p.id = req.providerId;
        p.name = req.name;
        p.description = req.description;
        p.endpointUrl = req.endpointUrl;
        p.authEndpointUrl = req.authEndpointUrl;
        p.clientId = req.clientId;
        
        repo.save(p);
        return CommandResult(true, p.id.value, "");
    }

    CommandResult updateTaskProvider(UpdateTaskProviderRequest req) {
        auto provider = repo.findById(req.tenantId, req.providerId);
        if (provider.isNull)
            return CommandResult(false, "", "Provider not found");

        if (req.name.length > 0) provider.name = req.name;
        if (req.description.length > 0) provider.description = req.description;
        if (req.endpointUrl.length > 0) provider.endpointUrl = req.endpointUrl;
        if (req.authEndpointUrl.length > 0) provider.authEndpointUrl = req.authEndpointUrl;
        if (req.clientId.length > 0) provider.clientId = req.clientId;
        provider.updatedBy = req.updatedBy;
        
        repo.update(provider);
        return CommandResult(true, provider.id.value, "");
    }

    CommandResult activate(TenantId tenantId, TaskProviderId id) {
        auto provider = repo.findById(tenantId, id);
        if (provider.isNull)
            return CommandResult(false, "", "Provider not found");
        provider.status = ProviderStatus.active;
        
        repo.update(provider);
        return CommandResult(true, provider.id.value, "");
    }

    CommandResult deactivate(TenantId tenantId, TaskProviderId id) {
        auto provider = repo.findById(tenantId, id);
        if (provider.isNull)
            return CommandResult(false, "", "Provider not found");

        provider.status = ProviderStatus.inactive;
        repo.update(provider);
        return CommandResult(true, provider.id.value, "");
    }

    CommandResult sync(TenantId tenantId, TaskProviderId id) {
        auto provider = repo.findById(tenantId, id);
        if (provider.isNull)
            return CommandResult(false, "", "Provider not found");

        provider.status = ProviderStatus.syncing;
        repo.update(provider);
        return CommandResult(true, provider.id.value, "");
    }

    CommandResult deleteTaskProvider(TenantId tenantId, TaskProviderId id) {
        auto provider = repo.findById(tenantId, id);
        if (provider.isNull)
            return CommandResult(false, "", "Provider not found");

        repo.remove(provider);
        return CommandResult(true, provider.id.value, "");
    }
}

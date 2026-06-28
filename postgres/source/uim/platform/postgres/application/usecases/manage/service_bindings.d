/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.service_bindings;

import uim.platform.postgres;

// mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase {
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo) { this.repo = repo; }

    ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id) {
        return repo.find(tenantId, id);
    }

    ServiceBinding[] listServiceBindings(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServiceBinding[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createServiceBinding(ServiceBindingDTO dto) {
        ServiceBinding e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.serviceBindingId;
        e.instanceId = dto.instanceId;
        e.appId = dto.appId;
        e.name = dto.name;
        e.sslMode = dto.sslMode;
        e.expiresAt = dto.expiresAt;
        e.status = BindingStatus.active;
        e.bindingPort = 5432;

        if (e.instanceId.value.length == 0 || e.appId.length == 0)
            return CommandResult(false, "", "instanceId and appId are required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id) {
        auto existing = repo.find(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service binding not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

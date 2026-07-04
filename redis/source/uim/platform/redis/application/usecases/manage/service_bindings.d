/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.service_bindings;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase {
    private ServiceBindingRepository repo;

    this(ServiceBindingRepository repo) { this.repo = repo; }

    ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id) {
        return repo.findById(tenantId, id);
    }

    ServiceBinding[] listServiceBindings(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceBinding[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    CommandResult createServiceBinding(ServiceBindingDTO dto) {
        if (!RedisValidator.isValidServiceBinding(ServiceBinding.init))
            return CommandResult(false, "", "Invalid binding: instanceId and appId required");

        auto e = ServiceBinding(dto.tenantId, dto.bindingId, dto.createdBy);
        e.instanceId = dto.instanceId;
        e.appId = dto.appId;
        e.name = dto.name;
        e.expiresAt = dto.expiresAt;
        e.status = BindingStatus.active;

        if (e.instanceId.isNull || e.appId.length == 0)
            return CommandResult(false, "", "Invalid binding: instanceId and appId required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service binding not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}

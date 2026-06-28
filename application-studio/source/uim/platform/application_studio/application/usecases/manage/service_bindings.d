/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.service_bindings;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
    private ServiceBindingRepository serviceBindings;

    this(ServiceBindingRepository serviceBindings) {
        this.serviceBindings = serviceBindings;
    }

    ServiceBinding getServiceBinding(TenantId tenantId, ServiceBindingId id) {
        return serviceBindings.findById(tenantId, id);
    }

    ServiceBinding[] listServiceBindings(TenantId tenantId) {
        return serviceBindings.find(tenantId);
    }

    ServiceBinding[] listServiceBindings(TenantId tenantId, DevSpaceId devSpaceId) {
        return serviceBindings.findByDevSpace(tenantId, devSpaceId);
    }

    CommandResult createServiceBinding(ServiceBindingDTO dto) {
        ServiceBinding e;
        e.id = dto.bindingId;
        e.tenantId = dto.tenantId;
        e.devSpaceId = dto.spaceId;
        e.name = dto.name;
        e.description = dto.description;
        e.serviceUrl = dto.serviceUrl;
        e.servicePath = dto.servicePath;
        e.authType = dto.authType;
        e.credentials = dto.credentials;
        e.systemAlias = dto.systemAlias;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidServiceBinding(e))
            return CommandResult(false, "", "Invalid service binding data");
        serviceBindings.save(e);
        return CommandResult(true, dto.bindingId.value, "");
    }

    CommandResult updateServiceBinding(ServiceBindingDTO dto) {
        auto existing = serviceBindings.findById(dto.tenantId, dto.bindingId);
        if (existing.isNull)
            return CommandResult(false, "", "Service binding not found");

        if (dto.name.length > 0)
            existing.name = dto.name;
        if (dto.description.length > 0)
            existing.description = dto.description;
        if (dto.serviceUrl.length > 0)
            existing.serviceUrl = dto.serviceUrl;
        if (!dto.updatedBy.isNull)
            existing.updatedBy = dto.updatedBy;

        serviceBindings.update(existing);
        return CommandResult(true, dto.bindingId.value, "");
    }

    CommandResult deleteServiceBinding(TenantId tenantId, ServiceBindingId id) {
        auto binding = serviceBindings.findById(tenantId, id);
        if (binding.isNull)
            return CommandResult(false, "", "Service binding not found");
            
        serviceBindings.remove(binding);
        return CommandResult(true, binding.id.value, "");
    }
}

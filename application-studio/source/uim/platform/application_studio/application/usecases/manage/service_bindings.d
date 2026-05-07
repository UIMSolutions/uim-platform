/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.service_bindings;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageServiceBindingsUseCase { // TODO: UIMUseCase {
    private ServiceBindingserviceBindingssitory serviceBindings;

    this(ServiceBindingserviceBindingssitory serviceBindings) {
        this.serviceBindings = serviceBindings;
    }

    ServiceBinding getById(ServiceBindingId id) {
        return serviceBindings.findById(tenantId, id);
    }

    ServiceBinding[] list() {
        return serviceBindings.findAll();
    }

    ServiceBinding[] listByTenant(TenantId tenantId) {
        return serviceBindings.findByTenant(tenantId);
    }

    ServiceBinding[] listByDevSpace(DevSpaceId devSpaceId) {
        return serviceBindings.findByDevSpace(devSpaceId);
    }

    CommandResult create(ServiceBindingDTO dto) {
        ServiceBinding e;
        e.id = ServiceBindingId(dto.id);
        e.tenantId = dto.tenantId;
        e.devSpaceId = DevSpaceId(dto.devSpaceId);
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
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult update(ServiceBindingDTO dto) {
        if (!serviceBindings.existsById(ServiceBindingId(dto.id)))
            return CommandResult(false, "", "Service binding not found");
        auto existing = serviceBindings.findById(ServiceBindingId(dto.id));
        if (dto.name.length > 0)
            existing.name = dto.name;
        if (dto.description.length > 0)
            existing.description = dto.description;
        if (dto.serviceUrl.length > 0)
            existing.serviceUrl = dto.serviceUrl;
        if (!dto.updatedBy.isNull)
            existing.updatedBy = dto.updatedBy;
        serviceBindings.update(existing);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult deleteServiceBinding(ServiceBindingId id) {
        auto binding = serviceBindings.findById(tenantId, id);
        if (binding.isNull)
            return CommandResult(false, "", "Service binding not found");
            
        serviceBindings.remove(binding);
        return CommandResult(true, binding.id.value, "");
    }
}

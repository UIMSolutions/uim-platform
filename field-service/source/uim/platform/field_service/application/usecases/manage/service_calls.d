/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.service_calls;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageServiceCallsUseCase { // TODO: UIMUseCase {
    private ServiceCallRepository repo;

    this(ServiceCallRepository repo) {
        this.repo = repo;
    }

    ServiceCall getServiceCall(TenantId tenantId, ServiceCallId id) {
        return repo.find(tenantId, id);
    }

    ServiceCall[] listServiceCalls(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServiceCall[] listServiceCalls(TenantId tenantId, ServiceCallStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    ServiceCall[] listServiceCalls(TenantId tenantId, ServiceCallPriority priority) {
        return repo.findByPriority(tenantId, priority);
    }

    CommandResult createServiceCall(ServiceCallDTO dto) {
        ServiceCall sc;
        sc.id = dto.serviceCallId;
        sc.tenantId = dto.tenantId;
        sc.customerId = dto.customerId;
        sc.equipmentId = dto.equipmentId;
        sc.subject = dto.subject;
        sc.description = dto.description;
        sc.serviceType = dto.serviceType;
        sc.contactPerson = dto.contactPerson;
        sc.contactPhone = dto.contactPhone;
        sc.contactEmail = dto.contactEmail;
        sc.reportedDate = dto.reportedDate;
        sc.dueDate = dto.dueDate;
        sc.address = dto.address;
        sc.latitude = dto.latitude;
        sc.longitude = dto.longitude;
        sc.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidServiceCall(sc))
            return CommandResult(false, "", "Invalid service call data");
        repo.save(sc);
        return CommandResult(true, sc.id.value, "");
    }

    CommandResult updateServiceCall(ServiceCallDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.serviceCallId);
        if (existing.isNull)
            return CommandResult(false, "", "Service call not found");
        if (dto.subject.length > 0) existing.subject = dto.subject;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.contactPerson.length > 0) existing.contactPerson = dto.contactPerson;
        if (dto.contactPhone.length > 0) existing.contactPhone = dto.contactPhone;
        if (dto.contactEmail.length > 0) existing.contactEmail = dto.contactEmail;
        if (dto.resolution.length > 0) existing.resolution = dto.resolution;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceCall(TenantId tenantId, ServiceCallId id) {
        auto entity = repo.find(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Service call not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

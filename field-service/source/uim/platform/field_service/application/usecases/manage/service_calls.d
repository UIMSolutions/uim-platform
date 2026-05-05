/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage.service_calls;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageServiceCallsUseCase { // TODO: UIMUseCase {
    private ServiceCallRepository repo;

    this(ServiceCallRepository repo) {
        this.repo = repo;
    }

    ServiceCall getById(ServiceCallId id) {
        return repo.findById(id);
    }

    ServiceCall[] list() {
        return repo.findAll();
    }

    ServiceCall[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ServiceCall[] listByStatus(ServiceCallStatus status) {
        return repo.findByStatus(status);
    }

    ServiceCall[] listByPriority(ServiceCallPriority priority) {
        return repo.findByPriority(priority);
    }

    CommandResult create(ServiceCallDTO dto) {
        ServiceCall sc;
        sc.id = dto.id;
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
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult update(ServiceCallDTO dto) {
        auto existing = repo.findById(dto.id);
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
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult remove(ServiceCallId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Service call not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}

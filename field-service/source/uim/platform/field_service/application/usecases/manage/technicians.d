/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.technicians;

import uim.platform.field_service;
mixin(ShowModule!());

@safe:

class ManageTechniciansUseCase { // TODO: UIMUseCase {
    private TechnicianRepository repo;

    this(TechnicianRepository repo) {
        this.repo = repo;
    }

    Technician getTechnician(TenantId tenantId, TechnicianId id) {
        return repo.findById(tenantId, id);
    }

    Technician[] listTechnicians(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Technician[] listTechnicians(TenantId tenantId, TechnicianStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Technician[] listTechnicians(TenantId tenantId, string region) {
        return repo.findByRegion(tenantId, region);
    }

    CommandResult createTechnician(TechnicianDTO dto) {
        Technician t;
        t.id = dto.technicianId;
        t.tenantId = dto.tenantId;
        t.firstName = dto.firstName;
        t.lastName = dto.lastName;
        t.email = dto.email;
        t.phone = dto.phone;
        t.region = dto.region;
        t.address = dto.address;
        t.latitude = dto.latitude;
        t.longitude = dto.longitude;
        t.availabilityStart = dto.availabilityStart;
        t.availabilityEnd = dto.availabilityEnd;
        t.maxWorkload = dto.maxWorkload;
        t.travelRadius = dto.travelRadius;
        t.createdBy = dto.createdBy;
        if (!FieldServiceValidator.isValidTechnician(t))
            return CommandResult(false, "", "Invalid technician data");
        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult updateTechnician(TechnicianDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.technicianId);
        if (existing.isNull)
            return CommandResult(false, "", "Technician not found");
        if (dto.firstName.length > 0) existing.firstName = dto.firstName;
        if (dto.lastName.length > 0) existing.lastName = dto.lastName;
        if (dto.email.length > 0) existing.email = dto.email;
        if (dto.phone.length > 0) existing.phone = dto.phone;
        if (dto.region.length > 0) existing.region = dto.region;
        if (dto.address.length > 0) existing.address = dto.address;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
        }

    CommandResult deleteTechnician(TenantId tenantId, TechnicianId id) {
        auto technician = repo.findById(tenantId, id);
        if (technician.isNull)
            return CommandResult(false, "", "Technician not found");

        repo.remove(technician);
        return CommandResult(true, technician.id.value, "");
    }
}

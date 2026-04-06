/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.application.usecases.manage.manage_technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class ManageTechniciansUseCase : UIMUseCase {
    private TechnicianRepository repo;

    this(TechnicianRepository repo) {
        this.repo = repo;
    }

    Technician* get_(TechnicianId id) {
        return repo.findById(id);
    }

    Technician[] list() {
        return repo.findAll();
    }

    Technician[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Technician[] listByStatus(TechnicianStatus status) {
        return repo.findByStatus(status);
    }

    Technician[] listByRegion(string region) {
        return repo.findByRegion(region);
    }

    CommandResult create(TechnicianDTO dto) {
        Technician t;
        t.id = dto.id;
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
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(TechnicianDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Technician not found");
        if (dto.firstName.length > 0) existing.firstName = dto.firstName;
        if (dto.lastName.length > 0) existing.lastName = dto.lastName;
        if (dto.email.length > 0) existing.email = dto.email;
        if (dto.phone.length > 0) existing.phone = dto.phone;
        if (dto.region.length > 0) existing.region = dto.region;
        if (dto.address.length > 0) existing.address = dto.address;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(TechnicianId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Technician not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.application.usecases.manage.manage_locations;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

class ManageLocationsUseCase : UIMUseCase {
    private LocationRepository repo;

    this(LocationRepository repo) {
        this.repo = repo;
    }

    Location* get_(LocationId id) {
        return repo.findById(id);
    }

    Location[] list() {
        return repo.findAll();
    }

    Location[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Location[] listByType(LocationType locationType) {
        return repo.findByType(locationType);
    }

    Location[] listByParent(LocationId parentId) {
        return repo.findByParent(parentId);
    }

    CommandResult create(LocationDTO dto) {
        Location l;
        l.id = dto.id;
        l.tenantId = dto.tenantId;
        l.name = dto.name;
        l.description = dto.description;
        l.parentLocationId = dto.parentLocationId;
        l.latitude = dto.latitude;
        l.longitude = dto.longitude;
        l.address = dto.address;
        l.building = dto.building;
        l.floor = dto.floor;
        l.room = dto.room;
        l.createdBy = dto.createdBy;
        if (!StrategyValidator.isValidLocation(l))
            return CommandResult(false, "", "Invalid location data");
        repo.save(l);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(LocationDTO dto) {
        auto existing = repo.findById(dto.id);
        if (existing is null)
            return CommandResult(false, "", "Location not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.address.length > 0) existing.address = dto.address;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(LocationId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Location not found");
        repo.remove(id);
        return CommandResult(true, id, "");
    }
}

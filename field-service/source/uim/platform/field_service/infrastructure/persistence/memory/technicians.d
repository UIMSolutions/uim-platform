/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryTechnicianRepository : TenantRepository!(Technician, TechnicianId), TechnicianRepository {

    size_t countByStatus(TenantId tenantId, TechnicianStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Technician[] filterByStatus(Technician[] technicians, TechnicianStatus status) {
        return technicians.filter!(e => e.status == status).array;
    }
    Technician[] findByStatus(TenantId tenantId, TechnicianStatus status) {
        return filterByStatus(find(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, TechnicianStatus status) {
        findByStatus(tenantId, status).each!(entity => remove(entity));
    }

    size_t countByRegion(TenantId tenantId, string region) {
        return findByRegion(tenantId, region).length;
    }
    Technician[] filterByRegion(Technician[] technicians, string region) {
        return technicians.filter!(e => e.region == region).array;
    }
    Technician[] findByRegion(TenantId tenantId, string region) {
        return filterByRegion(find(tenantId), region);
    }
    void removeByRegion(TenantId tenantId, string region) {
        findByRegion(tenantId, region).each!(entity => remove(entity));
    }

}

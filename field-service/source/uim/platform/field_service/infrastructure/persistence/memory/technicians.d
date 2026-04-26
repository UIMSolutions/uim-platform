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

    size_t countByStatus(TechnicianStatus status) {
        return findByStatus(status).length;
    }
    Technician[] filterByStatus(Technician[] technicians, TechnicianStatus status) {
        return technicians.filter!(e => e.status == status).array;
    }
    Technician[] findByStatus(TechnicianStatus status) {
        return findAll().filter!(e => e.status == status).array;
    }
    void removeByStatus(TechnicianStatus status) {
        findByStatus(status).each!(e => remove(e.id));
    }

    size_t countByRegion(string region) {
        return findByRegion(region).length;
    }
    Technician[] filterByRegion(Technician[] technicians, string region) {
        return technicians.filter!(e => e.region == region).array;
    }
    Technician[] findByRegion(string region) {
        return findAll().filter!(e => e.region == region).array;
    }
    void removeByRegion(string region) {
        findByRegion(region).each!(e => remove(e.id));
    }

}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.technician_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface TechnicianRepository {
    Technician[] findAll();
    Technician* findById(TechnicianId id);
    Technician[] findByTenant(TenantId tenantId);
    Technician[] findByStatus(TechnicianStatus status);
    Technician[] findByRegion(string region);
    void save(Technician technician);
    void update(Technician technician);
    void remove(TechnicianId id);
}

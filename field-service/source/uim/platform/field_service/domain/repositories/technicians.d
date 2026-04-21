/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface TechnicianRepository {
    bool existsById(TechnicianId id);
    Technician findById(TechnicianId id);
    
    Technician[] findAll();
    Technician[] findByTenant(TenantId tenantId);
    Technician[] findByStatus(TechnicianStatus status);
    Technician[] findByRegion(string region);
    
    void save(Technician technician);
    void update(Technician technician);
    void remove(TechnicianId id);
}

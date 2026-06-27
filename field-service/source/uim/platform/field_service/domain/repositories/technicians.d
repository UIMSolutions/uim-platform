/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface TechnicianRepository : ITentRepository!(Technician, TechnicianId) {

    size_t countByStatus(TenantId tenantId, TechnicianStatus status);
    Technician[] findByStatus(TenantId tenantId, TechnicianStatus status);
    void removeByStatus(TenantId tenantId, TechnicianStatus status);

    size_t countByRegion(TenantId tenantId, string region);    
    Technician[] findByRegion(TenantId tenantId, string region);    
    void removeByRegion(TenantId tenantId, string region);    

}

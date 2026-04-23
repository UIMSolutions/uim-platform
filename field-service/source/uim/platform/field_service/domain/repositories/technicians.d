/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.technicians;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface TechnicianRepository : ITenantRepository!(Technician, TechnicianId) {

    size_t countByStatus(TechnicianStatus status);
    Technician[] findByStatus(TechnicianStatus status);
    void removeByStatus(TechnicianStatus status);

    size_t countByRegion(string region);    
    Technician[] findByRegion(string region);    
    void removeByRegion(string region);    

}

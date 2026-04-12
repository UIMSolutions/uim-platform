/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.activities;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface ActivityRepository {
    Activity[] findAll();
    Activity* findById(ActivityId id);
    Activity[] findByTenant(TenantId tenantId);
    Activity[] findByServiceCall(ServiceCallId serviceCallId);
    Activity[] findByTechnician(TechnicianId technicianId);
    Activity[] findByStatus(ActivityStatus status);
    void save(Activity activity);
    void update(Activity activity);
    void remove(ActivityId id);
}

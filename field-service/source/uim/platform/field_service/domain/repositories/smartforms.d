/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.smartform_repository;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface SmartformRepository {
    Smartform[] findAll();
    Smartform* findById(SmartformId id);
    Smartform[] findByTenant(TenantId tenantId);
    Smartform[] findByServiceCall(ServiceCallId serviceCallId);
    Smartform[] findByActivity(ActivityId activityId);
    Smartform[] findByStatus(SmartformStatus status);
    void save(Smartform smartform);
    void update(Smartform smartform);
    void remove(SmartformId id);
}

/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.smartforms;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface SmartformRepository : ITenantRepository{

    size_t findByServiceCall(ServiceCallId serviceCallId);
    Smartform[] findByServiceCall(ServiceCallId serviceCallId);
    void removeByServiceCall(ServiceCallId serviceCallId);

    size_t findByActivity(ActivityId activityId);
    Smartform[] findByActivity(ActivityId activityId);
    void removeByActivity(ActivityId activityId);

    size_t findByStatus(SmartformStatus status);
    Smartform[] findByStatus(SmartformStatus status);
    void removeByStatus(SmartformStatus status);
    
}

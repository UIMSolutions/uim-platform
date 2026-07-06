/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.domain.types;

import uim.platform.service;

mixin(ShowModule!());

@safe:


struct UserId {
    mixin(IdTemplate);
}

struct GlobalAccountId {
    mixin(IdTemplate);
}

struct SubaccountId {
    mixin(IdTemplate);
}



struct ApplicationId {
    mixin(IdTemplate);
}


struct ConnectionId {
    mixin(IdTemplate);
}

struct OrganizationId {
    mixin(IdTemplate);
}

struct OrgId {
    mixin(IdTemplate);
}

struct ServiceBindingId {
  mixin(IdTemplate);
}

struct SpaceId {
    mixin(IdTemplate);
}

struct TenantId {
    mixin(IdTemplate);
}

struct ServiceInstanceId {
    mixin(IdTemplate);
}
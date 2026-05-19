/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.repositories.member_functions;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

interface MemberFunctionRepository : ITenantRepository!(MemberFunction, MemberFunctionId) {
    MemberFunction[] findByStatus(TenantId tenantId, FunctionStatus status);
    MemberFunction findByCode(TenantId tenantId, string code);
}

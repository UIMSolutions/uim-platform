/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.infrastructure.persistence.memory.member_functions;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class MemoryMemberFunctionRepository
    : TenantRepository!(MemberFunction, MemberFunctionId),
      MemberFunctionRepository {

    MemberFunction[] findByStatus(TenantId tenantId, FunctionStatus status) {
        return find(tenantId).filter!(f => f.status == status).array;
    }

    MemberFunction findByCode(TenantId tenantId, string code) {
        auto items = find(tenantId).filter!(f => f.code == code).array;
        return items.length > 0 ? items[0] : MemberFunction.init;
    }
}

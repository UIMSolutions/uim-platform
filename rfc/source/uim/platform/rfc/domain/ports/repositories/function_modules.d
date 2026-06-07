/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.ports.repositories.function_modules;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

interface FunctionModuleRepository {
    FunctionModule   findById(TenantId tenantId, FunctionModuleId id);
    FunctionModule[] findByTenant(TenantId tenantId);
    FunctionModule[] findByFunctionGroup(TenantId tenantId, string functionGroup);
    bool             save(FunctionModule fm);
    bool             update(FunctionModule fm);
    bool             remove(TenantId tenantId, FunctionModuleId id);
    size_t           countByTenant(TenantId tenantId);
}

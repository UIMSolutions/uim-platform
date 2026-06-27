/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.helpers.contains;

import uim.platform.service;

mixin(ShowModule!());

@safe:

bool containsTenantId(TenantId[] values, TenantId tenantId) {
  return values.any!(v => v == tenantId);
}

bool containsTenantId(string[] values, TenantId tenantId) {
  auto id = tenantId.value;
  return values.any!(v => v == id);
}

bool containsTenant(UUID[] ids, TenantId tenantId) {
  if (!tenantId.value.isUUID) {
    return false;
  }
  auto id = UUID(tenantId.value);
  return ids.any!(i => i == id);
}

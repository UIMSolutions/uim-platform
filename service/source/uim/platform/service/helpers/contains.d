module uim.platform.service.helpers.contains;

import uim.platform.service;

mixin(ShowModule!());

@safe:

bool containsTenant(string[] values, string tenantId) {
  return values.any!(v => v == tenantId);
}

bool containsTenant(string[] values, UUID tenantId) {
  return values.any!(v => v == tenantId.toString);
}

bool containsTenant(UUID[] ids, UUID tenantId) {
  return ids.any!(id => id == tenantId);
}

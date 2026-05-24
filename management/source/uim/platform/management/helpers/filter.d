module uim.platform.management.helpers.filter;

import uim.platform.management;

mixin(ShowModule!());

@safe:

T[] filterByGlobalAccount(T)(T[] items, GlobalAccountId globalAccountId) {
  return items.filter!(e => e.globalAccountId == globalAccountId).array;
}

T[] filterBySubAccount(T)(T[] items, SubAccountId subAccountId) {
  return items.filter!(e => e.subAccountId == subAccountId).array;
}

T[] filterByDirectory(T)(T[] items, DirectoryId directoryId) {
  return items.filter!(e => e.directoryId == directoryId).array;
}

T[] filterByStatus(T)(T[] items, DirectoryStatus status) {
  return items.filter!(e => e.status == status).array;
}


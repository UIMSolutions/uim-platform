module uim.platform.management.helpers.filters;

import uim.platform.management;

// mixin(ShowModule!());

@safe:

T[] filterByDirectory(T)(T[] items, DirectoryId directoryId) {
  return items.filter!(e => e.directoryId == directoryId).array;
}

T[] filterByStatus(T)(T[] items, DirectoryStatus status) {
  return items.filter!(e => e.status == status).array;
}


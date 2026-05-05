module uim.platform.service.helpers.filter;

import uim.platform.service;

mixin(ShowModule!());

@safe:

TEntity[] filterPaged(TEntity)(TEntity[] items, size_t offset, size_t limit, bool delegate(TEntity) pred = (TEntity e) => true) {
    TEntity[] result;
    size_t idx;
    if (offset >= items.length)
      return result;  

    foreach (e; items) {
      if (pred(e)) {
        if (idx >= offset && result.length < limit)
          result ~= e;
        idx++;

        if (result.length >= limit)
          break;
      }
    }
    return result;
  }

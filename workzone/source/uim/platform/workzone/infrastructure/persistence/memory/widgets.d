/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.widget;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.widget;
import uim.platform.workzone.domain.ports.repositories.widgets;

// import std.algorithm : filter;
// import std.array : array;

class MemoryWidgetRepository : WidgetRepository {
  private Widget[WidgetId] store;

  Widget[] findByPage(WorkpageId pagetenantId, id tenantId) {
    return store.byValue().filter!(w => w.tenantId == tenantId && w.pageId == pageId).array;
  }

  Widget* findById(WidgetId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  void save(Widget widget) {
    store[widget.id] = widget;
  }

  void update(Widget widget) {
    store[widget.id] = widget;
  }

  void remove(WidgetId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.widgets;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.widget;

interface WidgetRepository
{
  Widget[] findByPage(WorkpageId pageId, TenantId tenantId);
  Widget* findById(WidgetId id, TenantId tenantId);
  void save(Widget widget);
  void update(Widget widget);
  void remove(WidgetId id, TenantId tenantId);
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.page_widget;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A widget on a workpage. Shows exactly one integration card or business app.
struct PageWidget {
  mixin TenantEntity!WidgetId;

  WorkpageId workpageId;
  string workpageTitle;
  WorkspaceId workspaceId; /// derived from the workpage
  string title;
  CardId cardId;
  AppId appId;
  WidgetSize size = WidgetSize.medium;
  int row;
  int col; /// 0..3 (4 column grid)
  int sortOrder;
  bool visible = true;

  string customTitle;
  int maxItems;
  int refreshIntervalSec;
  string filterExpression;
  KeyValue[] parameters;
}

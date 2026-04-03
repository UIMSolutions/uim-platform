/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.widget;

import uim.platform.workzone.domain.types;

/// A widget instance placed on a workspace page.
struct Widget
{
  WidgetId id;
  WorkpageId pageId;
  TenantId tenantId;
  string title;
  CardId cardId; // references an integration card
  AppId appId; // or references a registered app
  WidgetSize size = WidgetSize.medium;
  int row;
  int col;
  int sortOrder;
  bool visible = true;
  WidgetConfig config;
  long createdAt;
  long updatedAt;
}

/// Per-instance widget configuration.
struct WidgetConfig
{
  string customTitle;
  int maxItems;
  int refreshIntervalSec;
  string filterExpression;
  string[string] parameters;
}

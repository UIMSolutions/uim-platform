/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.widget;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A widget instance placed on a workspace page.
struct Widget {
  mixin TenantEntity!(WidgetId);

  WorkpageId pageId;
  string title;
  CardId cardId; // references an integration card
  AppId appId; // or references a registered app
  WidgetSize size = WidgetSize.medium;
  int row;
  int col;
  int sortOrder;
  bool visible = true;
  WidgetConfig config;

  Json toJson() const {
    return entityToJson
      .set("pageId", pageId.value)
      .set("title", title)
      .set("cardId", cardId.value)
      .set("appId", appId.value)
      .set("size", size.toString())
      .set("row", row)
      .set("col", col)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("config", config.toJson());
  }
}

/// Per-instance widget configuration.
struct WidgetConfig {
  string customTitle;
  int maxItems;
  int refreshIntervalSec;
  string filterExpression;
  string[string] parameters;

  Json toJson() const {
    return Json.emptyObject
      .set("customTitle", customTitle)
      .set("maxItems", maxItems)
      .set("refreshIntervalSec", refreshIntervalSec)
      .set("filterExpression", filterExpression)
      .set("parameters", parameters);
  }
}

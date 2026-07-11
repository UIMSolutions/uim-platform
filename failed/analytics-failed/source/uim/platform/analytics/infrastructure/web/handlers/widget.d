/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.widget;

// import uim.platform.analytics.app.usecases.widgets;
// import uim.platform.analytics.app.dto.widget;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

class WidgetHandler {
  private WidgetUseCases useCases;

  this(WidgetUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listWidgets();
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = WidgetId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing widget id"), 400);
      return;
    }
    auto item = useCases.getWidget(id);
    if (item.id.isNull) {
      res.writeJsonBody(errorJson("Widget not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateWidgetRequest(json["title"].get!string,
          json["chartType"].get!string, json["datasetId"].get!string,
          UserId(json["userId"].get!string));
      res.writeJsonBody(toJsonValue(useCases.createWidget(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = WidgetId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing widget id"), 400);
      return;
    }
    useCases.deleteWidget(id);
    res.writeJsonBody(Json.emptyObject, 204);
  }
}


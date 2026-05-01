/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.dataset;

// import vibe.http.server;
// import vibe.data.json;
// import uim.platform.analytics.app.usecases.datasets;
// import uim.platform.analytics.app.dto.dataset;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

class DatasetHandler {
  private DatasetUseCases useCases;

  this(DatasetUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    res.writeJsonBody(toJsonArray(useCases.list()));
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "datasets");
    if (id.isEmpty) {
      res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest);
      return;
    }
    auto item = useCases.getById(id);
    if (item.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateDatasetRequest(json["name"].get!string,
          json["description"].get!string, json["dataSourceId"].get!string,
          json["userId"].get!string,);
      res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "datasets");
    useCases.removeById(id);
    res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
  }
}

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
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest);
      return;
    }
    auto item = useCases.getById(id);
    if (item.id.length == 0) {
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
      res.writeJsonBody(toJsonValue(result)("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "datasets");
    useCases.remove(id);
    res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
  }
}

private string extractIdFromPath(string uri, string resource) {
  // import std.string : split;
  auto parts = uri.split("/");
  foreach (i, part; parts)
    if (part == resource && i + 1 < parts.length && parts[i + 1].length > 0)
      return parts[i + 1];
  return "";
}

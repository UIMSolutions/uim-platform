/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.dataset;

// import uim.platform.analytics.app.usecases.datasets;
// import uim.platform.analytics.app.dto.dataset;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

class DatasetHandler {
  private DatasetUseCases useCases;

  this(DatasetUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listDatasets();
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = DatasetId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing dataset id"), 400);
      return;
    }
    auto item = useCases.getDataset(id);
    if (item.datasetId.isEmpty) {
      res.writeJsonBody(errorJson("Dataset not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateDatasetRequest(TenantId.init, ResourceGroupId.init,
          json["name"].get!string, json["description"].get!string,
          DataSourceId(json["dataSourceId"].get!string),
          UserId(json["userId"].get!string));
      res.writeJsonBody(toJsonValue(useCases.createDataset(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = DatasetId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing dataset id"), 400);
      return;
    }
    useCases.deleteDataset(id);
    res.writeJsonBody(Json.emptyObject, 204);
  }
}

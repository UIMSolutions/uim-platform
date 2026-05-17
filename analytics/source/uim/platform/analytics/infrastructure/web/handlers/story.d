/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.story;

// import uim.platform.analytics.app.usecases.stories;
// import uim.platform.analytics.app.dto.story;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

class StoryHandler {
  private StoryUseCases useCases;

  this(StoryUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listStories();
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing id"), 400);
      return;
    }
    auto item = useCases.getStory(id);
    if (item.id.length == 0) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateStoryRequest(json["title"].get!string,
          json["description"].get!string, json["ownerId"].get!string);
      res.writeJsonBody(toJsonValue(useCases.createStory(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void publish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    auto result = useCases.publishStory(id);
    if (result.id.length == 0) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    useCases.deleteStory(id);
    res.writeJsonBody(Json.emptyObject, 204);
  }
}



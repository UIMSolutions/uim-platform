module analytics.infrastructure.web.handlers.planning_handler;

import vibe.http.server;
import vibe.data.json;
import analytics.app.usecases.planning;
import analytics.app.dto.planning;
import analytics.infrastructure.web.json_utils;

class PlanningHandler {
    private PlanningUseCases useCases;

    this(PlanningUseCases useCases) {
        this.useCases = useCases;
    }

    void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeJsonBody(toJsonArray(useCases.list()));
    }

    void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "planning");
        if (id.length == 0) { res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest); return; }
        auto item = useCases.getById(id);
        if (item.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(item));
    }

    void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreatePlanningModelRequest(
                json["name"].get!string,
                json["description"].get!string,
                json["datasetId"].get!string,
                json["granularity"].get!string,
                json["userId"].get!string,
            );
            res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void lockModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "planning");
        auto result = useCases.lock(id);
        if (result.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(result));
    }

    void approveModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "planning");
        auto result = useCases.approve(id);
        if (result.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(result));
    }

    void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "planning");
        useCases.remove(id);
        res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
    }
}

private string extractIdFromPath(string uri, string resource) {
    import std.string : split;
    auto parts = uri.split("/");
    foreach (i, part; parts)
        if (part == resource && i + 1 < parts.length) {
            auto c = parts[i + 1];
            if (c.length > 0 && c != "lock" && c != "approve")
                return c;
        }
    return "";
}

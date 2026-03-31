module uim.platform.analytics.infrastructure.web.handlers.widget;

import vibe.http.server;
import vibe.data.json;
import uim.platform.analytics.app.usecases.widgets;
import uim.platform.analytics.app.dto.widget;
import uim.platform.analytics.infrastructure.web.json_utils;
@safe:

class WidgetHandler {
    private WidgetUseCases useCases;

    this(WidgetUseCases useCases) {
        this.useCases = useCases;
    }

    void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeJsonBody(toJsonArray(useCases.list()));
    }

    void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "widgets");
        if (id.length == 0) { res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest); return; }
        auto item = useCases.getById(id);
        if (item.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(item));
    }

    void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateWidgetRequest(
                json["name"].get!string,
                json["chartType"].get!string,
                json["datasetId"].get!string,
                json["userId"].get!string,
            );
            res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "widgets");
        useCases.remove(id);
        res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
    }
}

private string extractIdFromPath(string uri, string resource) {
    import std.string : split;
    auto parts = uri.split("/");
    foreach (i, part; parts)
        if (part == resource && i + 1 < parts.length && parts[i + 1].length > 0)
            return parts[i + 1];
    return "";
}

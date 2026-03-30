module uim.platform.analytics.infrastructure.web.handlers.story;

import vibe.http.server;
import vibe.data.json;
import uim.platform.analytics.app.usecases.stories;
import uim.platform.analytics.app.dto.story;
import uim.platform.analytics.infrastructure.web.json_utils;

class StoryHandler {
    private StoryUseCases useCases;

    this(StoryUseCases useCases) {
        this.useCases = useCases;
    }

    void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeJsonBody(toJsonArray(useCases.list()));
    }

    void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "stories");
        if (id.length == 0) { res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest); return; }
        auto item = useCases.getById(id);
        if (item.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(item));
    }

    void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateStoryRequest(
                json["title"].get!string,
                json["description"].get!string,
                json["ownerId"].get!string,
            );
            res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void publish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "stories");
        auto result = useCases.publish(id);
        if (result.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(result));
    }

    void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "stories");
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
            if (c != "publish" && c.length > 0) return c;
        }
    return "";
}

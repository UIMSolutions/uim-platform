module uim.platform.analytics.infrastructure.web.handlers.dashboard;

// import vibe.http.server;
import vibe.data.json;
import uim.platform.analytics.app.usecases.dashboards;
import uim.platform.analytics.app.dto.dashboard;
import uim.platform.analytics.infrastructure.web.json_utils;
@safe:

class DashboardHandler {
    private DashboardUseCases useCases;

    this(DashboardUseCases useCases) {
        this.useCases = useCases;
    }

    void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto items = useCases.list();
        res.writeJsonBody(toJsonArray(items));
    }

    void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractId(req);
        if (id.length == 0) {
            res.writeJsonBody(errorJson("Missing dashboard id"), HTTPStatus.badRequest);
            return;
        }
        auto item = useCases.getById(id);
        if (item.id.length == 0) {
            res.writeJsonBody(errorJson("Dashboard not found", 404), HTTPStatus.notFound);
            return;
        }
        res.writeJsonBody(toJsonValue(item));
    }

    void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto json = req.json;
            auto cmd = CreateDashboardRequest(
                json["name"].get!string,
                json["description"].get!string,
                json["ownerId"].get!string,
            );
            auto result = useCases.create(cmd);
            res.writeJsonBody(toJsonValue(result), HTTPStatus.created);
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void addPage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractId(req);
        try {
            auto json = req.json;
            auto result = useCases.addPage(id, json["title"].get!string);
            res.writeJsonBody(toJsonValue(result));
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void publish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractId(req);
        auto result = useCases.publish(id);
        if (result.id.length == 0) {
            res.writeJsonBody(errorJson("Dashboard not found", 404), HTTPStatus.notFound);
            return;
        }
        res.writeJsonBody(toJsonValue(result));
    }

    void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractId(req);
        useCases.remove(id);
        res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
    }
}

private string extractId(scope HTTPServerRequest req) {
    import std.conv : to;
    import std.string : split;
    auto path = req.requestURI;
    auto parts = path.split("/");
    // /api/v1/dashboards/{id}...
    foreach (i, part; parts) {
        if (part == "dashboards" && i + 1 < parts.length) {
            auto candidate = parts[i + 1];
            // Skip sub-resource keywords
            if (candidate != "publish" && candidate != "pages" && candidate.length > 0)
                return candidate;
        }
    }
    return "";
}

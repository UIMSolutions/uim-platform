module uim.platform.analytics.infrastructure.web.handlers.prediction;

import vibe.http.server;
import vibe.data.json;
import uim.platform.analytics.app.usecases.predictions;
import uim.platform.analytics.app.dto.prediction;
import uim.platform.analytics.infrastructure.web.json_utils;

class PredictionHandler {
    private PredictionUseCases useCases;

    this(PredictionUseCases useCases) {
        this.useCases = useCases;
    }

    void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeJsonBody(toJsonArray(useCases.list()));
    }

    void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "predictions");
        if (id.length == 0) { res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest); return; }
        auto item = useCases.getById(id);
        if (item.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(item));
    }

    void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto json = req.json;
            string[] features;
            if ("featureColumns" in json) {
                foreach (f; json["featureColumns"])
                    features ~= f.get!string;
            }
            auto cmd = CreatePredictionRequest(
                json["name"].get!string,
                json["description"].get!string,
                json["datasetId"].get!string,
                json["predictionType"].get!string,
                json["targetColumn"].get!string,
                features,
                json["userId"].get!string,
            );
            res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
        } catch (Exception e) {
            res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
        }
    }

    void train(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "predictions");
        auto result = useCases.train(id);
        if (result.id.length == 0) { res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound); return; }
        res.writeJsonBody(toJsonValue(result));
    }

    void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto id = extractIdFromPath(req.requestURI, "predictions");
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
            if (c.length > 0 && c != "train")
                return c;
        }
    return "";
}

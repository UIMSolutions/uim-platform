module uim.platform.architecture.presentation.ui5.controllers.architecture_blocks;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ArchitectureBlockUi5Controller {
    private ArchitectureBlockUi5Model model;
    private ArchitectureBlockUi5View view;

    this(ArchitectureBlockUi5Model model, ArchitectureBlockUi5View view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/ui5/architecture/architecture2", &handleArchitectureList);
        router.get("/ui5/architecture/architecture2/:id", &handleArchitectureDetail);
        router.post("/ui5/architecture/architecture2/create", &handleArchitectureCreate);
        router.post("/ui5/architecture/architecture2/:id/update", &handleArchitectureUpdate);
        router.post("/ui5/architecture/architecture2/:id/delete", &handleArchitectureDelete);
    }

    private void handleArchitectureList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.architecturePage(TenantId(t), t)));
    }

    private void handleArchitectureDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = req.params["id"];
        writeHtml(res, view.renderDetail(model.architectureDetail(TenantId(t), t, id)));
    }

    private string tenant(scope HTTPServerRequest req) {
        return req.query.get("tenantId", "default");
    }

    private void handleArchitectureCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto payload = req.json;

        CommandResult result;
        result = model.createArchitecture(TenantId(t), payload);

        auto status = result.isSuccess ? cast(int) HTTPStatus.created : cast(int) HTTPStatus.badRequest;
        writeJson(res, status, result);
    }

    private void handleArchitectureUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = req.params["id"];
        if (id.length == 0) {
            writeJsonError(res, cast(int) HTTPStatus.badRequest, "Missing block ID");
            return;
        }

        auto payload = req.json;
        CommandResult result;
        result = model.updateArchitecture(TenantId(t), id, payload);

        auto status = result.isSuccess ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        writeJson(res, status, result);
    }

    private void handleArchitectureDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = req.params["id"];
        if (id.length == 0) {
            writeJsonError(res, cast(int) HTTPStatus.badRequest, "Missing ID");
            return;
        }

        CommandResult result;
        result = model.deleteArchitecture(TenantId(t), id   );

        auto status = result.isSuccess ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
        writeJson(res, status, result);
    }

    private void writeHtml(scope HTTPServerResponse res, string html) {
        res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }

    private void writeJson(scope HTTPServerResponse res, int status, CommandResult result) {
        auto payload = Json.emptyObject;
        payload["success"] = Json(result.success);
        payload["id"] = Json(result.id);
        payload["message"] = Json(result.message);
        payload["code"] = Json(result.code);
        res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
    }

    private void writeJsonError(scope HTTPServerResponse res, int status, string message) {
        auto payload = Json.emptyObject;
        payload["success"] = Json(false);
        payload["id"] = Json("");
        payload["message"] = Json(message);
        payload["code"] = Json(cast(uint) status);
        res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
    }
}

module uim.platform.architecture.presentation.pwa.controllers.building_blocks;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockPwaController {
    private BuildingBlockPwaModel model;
    private BuildingBlockPwaView view;

    this(BuildingBlockPwaModel model, BuildingBlockPwaView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/pwa/architecture", &handleHub);

        router.get("/pwa/architecture/architecture", &handleArchitecture);
        router.get("/pwa/architecture/architecture/*", &handleArchitectureDetail);

        router.get("/pwa/architecture/solution", &handleSolution);
        router.get("/pwa/architecture/solution/*", &handleSolutionDetail);

        router.get("/pwa/architecture/data", &handleData);
        router.get("/pwa/architecture/data/*", &handleDataDetail);

        router.get("/pwa/architecture/business", &handleBusiness);
        router.get("/pwa/architecture/business/*", &handleBusinessDetail);

        router.get("/pwa/architecture/technology", &handleTechnology);
        router.get("/pwa/architecture/technology/*", &handleTechnologyDetail);

        router.get("/pwa/architecture/manifest.webmanifest", &handleManifest);
        router.get("/pwa/architecture/sw.js", &handleServiceWorker);
    }

    private void handleHub(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderHub(tenant(req)));
    }

    private void handleArchitecture(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderPage(model.architecturePage(TenantId(t), t)));
    }

    private void handleSolution(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderPage(model.solutionPage(TenantId(t), t)));
    }

    private void handleData(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderPage(model.dataPage(TenantId(t), t)));
    }

    private void handleBusiness(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderPage(model.businessPage(TenantId(t), t)));
    }

    private void handleTechnology(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderPage(model.technologyPage(TenantId(t), t)));
    }

    private void handleArchitectureDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderDetail(model.architectureDetail(TenantId(t), t, idFromPath(req.requestPath.to!string))));
    }

    private void handleSolutionDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderDetail(model.solutionDetail(TenantId(t), t, idFromPath(req.requestPath.to!string))));
    }

    private void handleDataDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderDetail(model.dataDetail(TenantId(t), t, idFromPath(req.requestPath.to!string))));
    }

    private void handleBusinessDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderDetail(model.businessDetail(TenantId(t), t, idFromPath(req.requestPath.to!string))));
    }

    private void handleTechnologyDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderDetail(model.technologyDetail(TenantId(t), t, idFromPath(req.requestPath.to!string))));
    }

    private void handleManifest(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeBody(view.manifest(), cast(int) HTTPStatus.ok, "application/manifest+json; charset=utf-8");
    }

    private void handleServiceWorker(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        res.writeBody(view.serviceWorker(), cast(int) HTTPStatus.ok, "application/javascript; charset=utf-8");
    }

    private string idFromPath(string path) {
        auto idx = path.lastIndexOf('/');
        if (idx < 0 || idx + 1 >= path.length)
            return "";
        return path[idx + 1 .. $];
    }

    private void writeHtml(scope HTTPServerResponse res, string html) {
        res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
    }
}

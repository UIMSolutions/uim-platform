module uim.platform.architecture.presentation.ui5.controllers.building_blocks;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockUi5Controller {
    private BuildingBlockUi5Model model;
    private BuildingBlockUi5View view;

    this(BuildingBlockUi5Model model, BuildingBlockUi5View view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/ui5/architecture", &handleHub);

        router.get("/ui5/architecture/architecture", &handleArchitecture);
        router.get("/ui5/architecture/architecture/*", &handleArchitectureDetail);

        router.get("/ui5/architecture/solution", &handleSolution);
        router.get("/ui5/architecture/solution/*", &handleSolutionDetail);

        router.get("/ui5/architecture/data", &handleData);
        router.get("/ui5/architecture/data/*", &handleDataDetail);

        router.get("/ui5/architecture/business", &handleBusiness);
        router.get("/ui5/architecture/business/*", &handleBusinessDetail);

        router.get("/ui5/architecture/technology", &handleTechnology);
        router.get("/ui5/architecture/technology/*", &handleTechnologyDetail);
    }

    private void handleHub(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        writeHtml(res, view.renderHub(tenant(req)));
    }

    private void handleArchitecture(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.architecturePage(TenantId(t), t)));
    }

    private void handleSolution(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.solutionPage(TenantId(t), t)));
    }

    private void handleData(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.dataPage(TenantId(t), t)));
    }

    private void handleBusiness(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.businessPage(TenantId(t), t)));
    }

    private void handleTechnology(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        writeHtml(res, view.renderOverview(model.technologyPage(TenantId(t), t)));
    }

    private void handleArchitectureDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = idFromPath(req.requestPath.to!string);
        writeHtml(res, view.renderDetail(model.architectureDetail(TenantId(t), t, id)));
    }

    private void handleSolutionDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = idFromPath(req.requestPath.to!string);
        writeHtml(res, view.renderDetail(model.solutionDetail(TenantId(t), t, id)));
    }

    private void handleDataDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = idFromPath(req.requestPath.to!string);
        writeHtml(res, view.renderDetail(model.dataDetail(TenantId(t), t, id)));
    }

    private void handleBusinessDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = idFromPath(req.requestPath.to!string);
        writeHtml(res, view.renderDetail(model.businessDetail(TenantId(t), t, id)));
    }

    private void handleTechnologyDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        auto t = tenant(req);
        auto id = idFromPath(req.requestPath.to!string);
        writeHtml(res, view.renderDetail(model.technologyDetail(TenantId(t), t, id)));
    }

    private string tenant(scope HTTPServerRequest req) {
        return req.query.get("tenantId", "default");
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

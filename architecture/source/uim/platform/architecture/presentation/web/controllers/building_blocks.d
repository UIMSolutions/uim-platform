module uim.platform.architecture.presentation.web.controllers.building_blocks;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockWebController {
    private BuildingBlockWebModel model;
    private BuildingBlockWebView view;

    this(BuildingBlockWebModel model, BuildingBlockWebView view) {
        this.model = model;
        this.view = view;
    }

    void registerRoutes(URLRouter router) {
        router.get("/web/login", &getLogin);
        router.post("/web/login", &handleLogin);
        router.get("/web/logout", &handleLogout);
        router.get("/web", &handleIndex);
        // router.get("/web/architecture", &handleArchitecture);
        router.get("/web/solutions", &handleSolution);
        router.get("/web/data", &handleData);
        router.get("/web/business", &handleBusiness);
        router.get("/web/technology", &handleTechnology);
        router.get("/web/contact", &handleContact);
        router.get("/web/settings", &handleSettings);

//        router.get("/web/architecture", &webArchitecture);
//        router.get("/web/architecture/architecture", &handleArchitecture);
//        router.get("/web/architecture/architecture/*", &handleArchitectureDetails);
//        router.get("/web/architecture/solution", &handleSolution);
//        router.get("/web/architecture/solution/*", &handleSolutionDetails);
//        router.get("/web/architecture/data", &handleData);
//        router.get("/web/architecture/data/*", &handleDataDetails);
//        router.get("/web/architecture/business", &handleBusiness);
//        router.get("/web/architecture/business/*", &handleBusinessDetails);
//        router.get("/web/architecture/technology", &handleTechnology);
//        router.get("/web/architecture/technology/*", &handleTechnologyDetails);
    }

    // private void handleHub(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderHub(tenant));
    // }

    // private void handleArchitecture(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderPage(model.architecturePage(TenantId(tenant), tenant)));
    // }

    // private void handleArchitectureDetails(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     auto id = idFromPath(req.requestPath.to!string);
    //     writeHtml(res, view.renderDetail(model.architectureDetails(TenantId(tenant), tenant, id)));
    // }

    // private void handleSolution(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderPage(model.solutionPage(TenantId(tenant), tenant)));
    // }

    // private void handleSolutionDetails(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     auto id = idFromPath(req.requestPath.to!string);
    //     writeHtml(res, view.renderDetail(model.solutionDetails(TenantId(tenant), tenant, id)));
    // }

    // private void handleData(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderPage(model.dataPage(TenantId(tenant), tenant)));
    // }

    // private void handleDataDetails(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     auto id = idFromPath(req.requestPath.to!string);
    //     writeHtml(res, view.renderDetail(model.dataDetails(TenantId(tenant), tenant, id)));
    // }

    // private void handleBusiness(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderPage(model.businessPage(TenantId(tenant), tenant)));
    // }

    // private void handleBusinessDetails(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     auto id = idFromPath(req.requestPath.to!string);
    //     writeHtml(res, view.renderDetail(model.businessDetails(TenantId(tenant), tenant, id)));
    // }

    // private void handleTechnology(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     writeHtml(res, view.renderPage(model.technologyPage(TenantId(tenant), tenant)));
    // }

    // private void handleTechnologyDetails(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    //     auto tenant = tenantLabel(req);
    //     auto id = idFromPath(req.requestPath.to!string);
    //     writeHtml(res, view.renderDetail(model.technologyDetails(TenantId(tenant), tenant, id)));
    // }

    private string tenantLabel(scope HTTPServerRequest req) {
        return req.query.get("tenantId", "default");
    }

    private string idFromPath(string path) {
        auto idx = path.lastIndexOf('/');
        if (idx < 0 || idx + 1 >= path.length)
            return "";
        return path[idx + 1 .. $];
    }
}

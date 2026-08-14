module uim.platform.architecture.presentation.uix5.controllers.building_blocks;

import std.conv : to;
import std.string : lastIndexOf;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

// class BuildingBlockUi5Controller {
//     private BuildingBlockUi5Model model;
//     private BuildingBlockUi5View view;

//     this(BuildingBlockUi5Model model, BuildingBlockUi5View view) {
//         this.model = model;
//         this.view = view;
//     }

//     void registerRoutes(URLRouter router) {
//         router.get("/ui5/architecture", &handleHub);

//         router.get("/ui5/architecture/architecture", &handleArchitecture);
//         router.get("/ui5/architecture/architecture/:id", &handleArchitectureDetail);
//         router.post("/ui5/architecture/architecture/create", &handleArchitectureCreate);
//         router.post("/ui5/architecture/architecture/:id/update", &handleArchitectureUpdate);
//         router.post("/ui5/architecture/architecture/:id/delete", &handleArchitectureDelete);

//         router.get("/ui5/architecture/solution", &handleSolution);
//         router.get("/ui5/architecture/solution/:id", &handleSolutionDetail);
//         router.post("/ui5/architecture/solution/create", &handleSolutionCreate);
//         router.post("/ui5/architecture/solution/:id/update", &handleSolutionUpdate);
//         router.post("/ui5/architecture/solution/:id/delete", &handleSolutionDelete);

//         router.get("/ui5/architecture/data", &handleData);
//         router.get("/ui5/architecture/data/:id", &handleDataDetail);
//         router.post("/ui5/architecture/data/create", &handleDataCreate);
//         router.post("/ui5/architecture/data/:id/update", &handleDataUpdate);
//         router.post("/ui5/architecture/data/:id/delete", &handleDataDelete);

//         router.get("/ui5/architecture/business", &handleBusiness);
//         router.get("/ui5/architecture/business/:id", &handleBusinessDetail);
//         router.post("/ui5/architecture/business/create", &handleBusinessCreate);
//         router.post("/ui5/architecture/business/:id/update", &handleBusinessUpdate);
//         router.post("/ui5/architecture/business/:id/delete", &handleBusinessDelete);

//         router.get("/ui5/architecture/technology", &handleTechnology);
//         router.get("/ui5/architecture/technology/*", &handleTechnologyDetail);
//         router.post("/ui5/architecture/technology/create", &handleTechnologyCreate);
//         router.post("/ui5/architecture/technology/:id/update", &handleTechnologyUpdate);
//         router.post("/ui5/architecture/technology/:id/delete", &handleTechnologyDelete);
//     }

//     private void handleHub(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         writeHtml(res, view.renderHub(tenant(req)));
//     }

//     private void handleArchitecture(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         writeHtml(res, view.renderOverview(model.architecturePage(TenantId(t), t)));
//     }

//     private void handleSolution(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         writeHtml(res, view.renderOverview(model.solutionPage(TenantId(t), t)));
//     }

//     private void handleData(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         writeHtml(res, view.renderOverview(model.dataPage(TenantId(t), t)));
//     }

//     private void handleBusiness(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         writeHtml(res, view.renderOverview(model.businessPage(TenantId(t), t)));
//     }

//     private void handleTechnology(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         writeHtml(res, view.renderOverview(model.technologyPage(TenantId(t), t)));
//     }

//     private void handleArchitectureDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         auto id = req.params["id"];
//         writeHtml(res, view.renderDetail(model.architectureDetail(TenantId(t), t, id)));
//     }

//     private void handleSolutionDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         auto id = req.params["id"];
//         writeHtml(res, view.renderDetail(model.solutionDetail(TenantId(t), t, id)));
//     }

//     private void handleDataDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         auto id = req.params["id"];
//         writeHtml(res, view.renderDetail(model.dataDetail(TenantId(t), t, id)));
//     }

//     private void handleBusinessDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         auto id = req.params["id"];
//         writeHtml(res, view.renderDetail(model.businessDetail(TenantId(t), t, id)));
//     }

//     private void handleTechnologyDetail(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         auto t = tenant(req);
//         auto id = req.params["id"];
//         writeHtml(res, view.renderDetail(model.technologyDetail(TenantId(t), t, id)));
//     }

//     private void handleArchitectureCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleCreate(req, res, "architecture");
//     }

//     private void handleSolutionCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleCreate(req, res, "solution");
//     }

//     private void handleDataCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleCreate(req, res, "data");
//     }

//     private void handleBusinessCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleCreate(req, res, "business");
//     }

//     private void handleTechnologyCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleCreate(req, res, "technology");
//     }

//     private void handleArchitectureUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleUpdate(req, res, "architecture");
//     }

//     private void handleSolutionUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleUpdate(req, res, "solution");
//     }

//     private void handleDataUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleUpdate(req, res, "data");
//     }

//     private void handleBusinessUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleUpdate(req, res, "business");
//     }

//     private void handleTechnologyUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleUpdate(req, res, "technology");
//     }

//     private void handleArchitectureDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleDelete(req, res, "architecture");
//     }

//     private void handleSolutionDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleDelete(req, res, "solution");
//     }

//     private void handleDataDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleDelete(req, res, "data");
//     }

//     private void handleBusinessDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleDelete(req, res, "business");
//     }

//     private void handleTechnologyDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
//         handleDelete(req, res, "technology");
//     }

//     private string tenant(scope HTTPServerRequest req) {
//         return req.query.get("tenantId", "default");
//     }

//     private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res, string blockType) {
//         auto t = tenant(req);
//         auto payload = req.json;

//         CommandResult result;
//         final switch (blockType) {
//             case "architecture": result = model.createArchitecture(TenantId(t), payload); break;
//             case "solution": result = model.createSolution(TenantId(t), payload); break;
//             case "data": result = model.createData(TenantId(t), payload); break;
//             case "business": result = model.createBusiness(TenantId(t), payload); break;
//             case "technology": result = model.createTechnology(TenantId(t), payload); break;
//         }

//         auto status = result.isSuccess ? cast(int) HTTPStatus.created : cast(int) HTTPStatus.badRequest;
//         writeJson(res, status, result);
//     }

//     private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res, string blockType) {
//         auto t = tenant(req);
//         auto path = req.requestPath.to!string;
//         auto id = detailIdFromActionPath(path);
//         if (id.length == 0) {
//             writeJsonError(res, cast(int) HTTPStatus.badRequest, "Missing block ID");
//             return;
//         }

//         auto payload = req.json;
//         CommandResult result;
//         final switch (blockType) {
//             case "architecture": result = model.updateArchitecture(TenantId(t), id, payload); break;
//             case "solution": result = model.updateSolution(TenantId(t), id, payload); break;
//             case "data": result = model.updateData(TenantId(t), id, payload); break;
//             case "business": result = model.updateBusiness(TenantId(t), id, payload); break;
//             case "technology": result = model.updateTechnology(TenantId(t), id, payload); break;
//         }

//         auto status = result.isSuccess ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
//         writeJson(res, status, result);
//     }

//     private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res, string blockType) {
//         auto t = tenant(req);
//         auto path = req.requestPath.to!string;
//         auto id = detailIdFromActionPath(path);
//         if (id.length == 0) {
//             writeJsonError(res, cast(int) HTTPStatus.badRequest, "Missing block ID");
//             return;
//         }

//         CommandResult result;
//         final switch (blockType) {
//             case "architecture": result = model.deleteArchitecture(TenantId(t), id); break;
//             case "solution": result = model.deleteSolution(TenantId(t), id); break;
//             case "data": result = model.deleteData(TenantId(t), id); break;
//             case "business": result = model.deleteBusiness(TenantId(t), id); break;
//             case "technology": result = model.deleteTechnology(TenantId(t), id); break;
//         }

//         auto status = result.isSuccess ? cast(int) HTTPStatus.ok : cast(int) HTTPStatus.notFound;
//         writeJson(res, status, result);
//     }

//     private string idFromPath(string path) {
//         auto idx = path.lastIndexOf('/');
//         if (idx < 0 || idx + 1 >= path.length)
//             return "";
//         return path[idx + 1 .. $];
//     }

//     private string detailIdFromActionPath(string path) {
//         static immutable markers = ["/update", "/delete"];
//         foreach (marker; markers) {
//             auto markerIndex = path.lastIndexOf(marker);
//             if (markerIndex <= 0)
//                 continue;
//             auto slice = path[0 .. markerIndex];
//             return idFromPath(slice);
//         }
//         return "";
//     }

//     private void writeHtml(scope HTTPServerResponse res, string html) {
//         res.writeBody(html, cast(int) HTTPStatus.ok, "text/html; charset=utf-8");
//     }

//     private void writeJson(scope HTTPServerResponse res, int status, CommandResult result) {
//         auto payload = Json.emptyObject;
//         payload["success"] = Json(result.success);
//         payload["id"] = Json(result.id);
//         payload["message"] = Json(result.message);
//         payload["code"] = Json(result.code);
//         res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
//     }

//     private void writeJsonError(scope HTTPServerResponse res, int status, string message) {
//         auto payload = Json.emptyObject;
//         payload["success"] = Json(false);
//         payload["id"] = Json("");
//         payload["message"] = Json(message);
//         payload["code"] = Json(cast(uint) status);
//         res.writeBody(payload.toString(), status, "application/json; charset=utf-8");
//     }
// }

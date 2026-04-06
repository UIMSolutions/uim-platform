/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.controllers.company_profile;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

class CompanyProfileController : SAPController {
    private ManageCompanyProfilesUseCase uc;

    this(ManageCompanyProfilesUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        super.registerRoutes(router);
        router.get("/api/v1/network-asset-collaboration/companies", &handleList);
        router.get("/api/v1/network-asset-collaboration/companies/*", &handleGet);
        router.post("/api/v1/network-asset-collaboration/companies", &handleCreate);
        router.put("/api/v1/network-asset-collaboration/companies/*", &handleUpdate);
        router.delete_("/api/v1/network-asset-collaboration/companies/*", &handleDelete);
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto items = uc.list();
            auto jarr = Json.emptyArray;
            foreach (ref cp; items) jarr ~= companyProfileToJson(cp);
            auto resp = Json.emptyObject;
            resp["count"] = Json(cast(long) items.length);
            resp["resources"] = jarr;
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto cp = uc.get_(id);
            if (cp is null) { writeError(res, 404, "Company profile not found"); return; }
            res.writeJsonBody(companyProfileToJson(*cp), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            CompanyProfileDTO dto;
            dto.id = jsonStr(j, "id");
            dto.tenantId = req.headers.get("X-Tenant-Id", "");
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.industry = jsonStr(j, "industry");
            dto.website = jsonStr(j, "website");
            dto.contactEmail = jsonStr(j, "contactEmail");
            dto.contactPhone = jsonStr(j, "contactPhone");
            dto.addressStreet = jsonStr(j, "addressStreet");
            dto.addressCity = jsonStr(j, "addressCity");
            dto.addressState = jsonStr(j, "addressState");
            dto.addressCountry = jsonStr(j, "addressCountry");
            dto.addressPostalCode = jsonStr(j, "addressPostalCode");
            dto.createdBy = jsonStr(j, "createdBy");

            auto result = uc.create(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Company profile created");
                res.writeJsonBody(resp, 201);
            } else {
                writeError(res, 400, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto j = req.json;
            CompanyProfileDTO dto;
            dto.id = extractIdFromPath(path);
            dto.name = jsonStr(j, "name");
            dto.description = jsonStr(j, "description");
            dto.contactEmail = jsonStr(j, "contactEmail");
            dto.contactPhone = jsonStr(j, "contactPhone");
            dto.modifiedBy = jsonStr(j, "modifiedBy");

            auto result = uc.update(dto);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["id"] = Json(result.id);
                resp["message"] = Json("Company profile updated");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            import std.conv : to;
            auto path = req.requestURI.to!string;
            auto id = extractIdFromPath(path);
            auto result = uc.remove(id);
            if (result.success) {
                auto resp = Json.emptyObject;
                resp["message"] = Json("Company profile deleted");
                res.writeJsonBody(resp, 200);
            } else {
                writeError(res, 404, result.error);
            }
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }
}

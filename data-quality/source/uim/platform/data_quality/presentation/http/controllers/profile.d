module uim.platform.data - quality.presentation.http.controllers.profile;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.xyz.application.usecases.profile_data;
import uim.platform.xyz.application.dto;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.data_profile;
import uim.platform.xyz.presentation.http.json_utils;

class ProfileController {
    private ProfileDataUseCase uc;

    this(ProfileDataUseCase uc) {
        this.uc = uc;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/profiles", &handleProfile);
        router.get("/api/v1/profiles", &handleList);
        router.get("/api/v1/profiles/*", &handleGetById);
    }

    private void handleProfile(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto r = ProfileDatasetRequest();
            r.tenantId = req.headers.get("X-Tenant-Id", "");
            r.datasetId = j.getString("datasetId");
            r.datasetName = j.getString("datasetName");

            auto recordsJson = "records" in j;
            if (recordsJson !is null && (*recordsJson).type == Json.Type.array) {
                foreach (item; *recordsJson) {
                    if (item.type == Json.Type.object) {
                        ProfileRecordInput pri;
                        pri.recordId = item.getString("recordId");
                        pri.fieldValues = jsonStrMap(item, "fieldValues");
                        r.records ~= pri;
                    }
                }
            }

            auto profile = uc.profile(r);
            res.writeJsonBody(serializeProfile(profile), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto profiles = uc.listByTenant(tenantId);
            auto arr = Json.emptyArray;
            foreach (ref p; profiles)
                arr ~= serializeProfile(p);

            auto resp = Json.emptyObject;
            resp["items"] = arr;
            resp["totalCount"] = Json(cast(long)profiles.length);
            res.writeJsonBody(resp, 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto id = extractIdFromPath(req.requestURI);
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto profile = uc.getById(id, tenantId);
            if (profile is null) {
                writeError(res, 404, "Data profile not found");
                return;
            }
            res.writeJsonBody(serializeProfile(*profile), 200);
        } catch (Exception e) {
            writeError(res, 500, "Internal server error");
        }
    }

    private static Json serializeProfile(ref const DataProfile p) {
        auto j = Json.emptyObject;
        j["id"] = Json(p.id);
        j["tenantId"] = Json(p.tenantId);
        j["datasetId"] = Json(p.datasetId);
        j["datasetName"] = Json(p.datasetName);
        j["totalRecords"] = Json(p.totalRecords);
        j["profiledRecords"] = Json(p.profiledRecords);
        j["overallQualityScore"] = Json(p.overallQualityScore);
        j["rating"] = Json(p.rating.to!string);
        j["profiledAt"] = Json(p.profiledAt);
        j["duration"] = Json(p.duration);

        auto cols = Json.emptyArray;
        foreach (ref c; p.columns) {
            auto cj = Json.emptyObject;
            cj["fieldName"] = Json(c.fieldName);
            cj["detectedType"] = Json(c.detectedType.to!string);
            cj["totalValues"] = Json(c.totalValues);
            cj["nullCount"] = Json(c.nullCount);
            cj["emptyCount"] = Json(c.emptyCount);
            cj["uniqueCount"] = Json(c.uniqueCount);
            cj["duplicateCount"] = Json(c.duplicateCount);
            cj["completeness"] = Json(c.completeness);
            cj["uniqueness"] = Json(c.uniqueness);
            cj["validity"] = Json(c.validity);
            cj["minLength"] = Json(c.minLength);
            cj["maxLength"] = Json(c.maxLength);
            cj["avgLength"] = Json(c.avgLength);

            if (c.topValues.length > 0) {
                auto tv = Json.emptyArray;
                foreach (v; c.topValues)
                    tv ~= Json(v);
                cj["topValues"] = tv;
            }
            cols ~= cj;
        }
        j["columns"] = cols;

        return j;
    }
}

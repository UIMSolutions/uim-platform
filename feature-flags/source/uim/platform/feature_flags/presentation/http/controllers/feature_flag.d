/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.presentation.http.controllers.feature_flag;

import uim.platform.feature_flags;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPStatus;
import vibe.data.json   : Json;
import std.algorithm    : map;
import std.array        : array;
import std.conv         : to;

// mixin(ShowModule!());

@safe:

class FeatureFlagController {
    private ManageFeatureFlagsUseCase useCase;

    this(ManageFeatureFlagsUseCase useCase) {
        this.useCase = useCase;
    }

    void registerRoutes(URLRouter router) {
        router.get   ("/api/v1/feature-flags/flags",      &handleList);
        router.post  ("/api/v1/feature-flags/flags",      &handleCreate);
        router.get   ("/api/v1/feature-flags/flags/*",    &handleGet);
        router.put   ("/api/v1/feature-flags/flags/*",    &handleUpdate);
        router.patch ("/api/v1/feature-flags/flags/*",    &handlePatch);
        router.delete_("/api/v1/feature-flags/flags/*",  &handleDelete);
    }

    // GET /api/v1/feature-flags/flags?instanceId=...&tenantId=...
    private void handleList(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId   = req.query.get("tenantId",   "default");
        auto instanceId = req.query.get("instanceId", "");

        FeatureFlag[] flags;
        if (instanceId.length > 0)
            flags = useCase.listFlagsByInstance(tenantId, ServiceInstanceId(instanceId));
        else
            flags = useCase.listFlags(tenantId);

        auto jarr = Json.emptyArray;
        foreach (f; flags) jarr ~= toJson(f);

        auto j = Json.emptyObject;
        j["count"]     = cast(long) flags.length;
        j["resources"] = jarr;
        res.writeJsonBody(j, cast(int) HTTPStatus.ok);
    }

    // POST /api/v1/feature-flags/flags
    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto body_ = req.json;
        if (body_.type == Json.Type.undefined) {
            writeError(res, cast(int) HTTPStatus.badRequest, "Request body required");
            return;
        }

        CreateFeatureFlagRequest dto;
        dto.name           = getString(body_, "name");
        dto.description    = getString(body_, "description");
        dto.type_          = getString(body_, "type", "BOOLEAN");
        dto.instanceId     = getString(body_, "instanceId");
        dto.defaultVariant = getString(body_, "defaultVariant", "off");
        dto.labels         = getStringMap(body_, "labels");
        dto.createdBy      = getString(body_, "createdBy");

        auto varArr = body_["variants"];
        if (varArr.isArray)
            foreach (v; varArr) dto.variants ~= parseVariantDTO(v);

        auto ruleArr = body_["rules"];
        if (ruleArr.isArray)
            foreach (r; ruleArr) dto.rules ~= parseRuleDTO(r);

        auto result = useCase.createFlag(dto);
        if (result.hasError) {
            writeError(res, cast(int) HTTPStatus.badRequest, result.message);
            return;
        }
        auto j = Json.emptyObject;
        j["id"]      = result.id;
        j["message"] = "Feature flag created";
        res.writeJsonBody(j, cast(int) HTTPStatus.created);
    }

    // GET /api/v1/feature-flags/flags/:id?tenantId=...
    private void handleGet(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path     = req.requestPath.to!string;
        auto id       = FlagId(extractIdFromPath(path));
        if (id.isNull) { writeError(res, 400, "Invalid flag ID"); return; }

        auto flag_ = useCase.getFlag(tenantId, id);
        if (flag_.isNull) { writeError(res, 404, "Feature flag not found"); return; }

        res.writeJsonBody(toJson(flag_), cast(int) HTTPStatus.ok);
    }

    // PUT /api/v1/feature-flags/flags/:id
    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path     = req.requestPath.to!string;
        auto id       = FlagId(extractIdFromPath(path));
        if (id.isNull) { writeError(res, 400, "Invalid flag ID"); return; }

        auto body_ = req.json;
        if (body_.type == Json.Type.undefined) {
            writeError(res, cast(int) HTTPStatus.badRequest, "Request body required");
            return;
        }

        UpdateFeatureFlagRequest dto;
        dto.description    = getString(body_, "description");
        dto.defaultVariant = getString(body_, "defaultVariant");
        dto.labels         = getStringMap(body_, "labels");
        dto.updatedBy      = getString(body_, "updatedBy");

        auto varArr = body_["variants"];
        if (varArr.isArray)
            foreach (v; varArr) dto.variants ~= parseVariantDTO(v);

        auto ruleArr = body_["rules"];
        if (ruleArr.isArray)
            foreach (r; ruleArr) dto.rules ~= parseRuleDTO(r);

        auto result = useCase.updateFlag(tenantId, id, dto);
        if (result.hasError) { writeError(res, 400, result.message); return; }

        auto j = Json.emptyObject;
        j["id"]      = result.id;
        j["message"] = "Feature flag updated";
        res.writeJsonBody(j, cast(int) HTTPStatus.ok);
    }

    // PATCH /api/v1/feature-flags/flags/:id  (state transition)
    private void handlePatch(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId = req.query.get("tenantId", "default");
        auto path     = req.requestPath.to!string;
        auto id       = FlagId(extractIdFromPath(path));
        if (id.isNull) { writeError(res, 400, "Invalid flag ID"); return; }

        auto body_ = req.json;
        PatchFeatureFlagRequest dto;
        dto.state_    = getString(body_, "state");
        dto.updatedBy = getString(body_, "updatedBy");

        auto result = useCase.patchFlagState(tenantId, id, dto);
        if (result.hasError) { writeError(res, 400, result.message); return; }

        auto j = Json.emptyObject;
        j["id"]      = result.id;
        j["message"] = "Feature flag state updated";
        res.writeJsonBody(j, cast(int) HTTPStatus.ok);
    }

    // DELETE /api/v1/feature-flags/flags/:id
    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res) @safe {
        auto tenantId  = req.query.get("tenantId", "default");
        auto path      = req.requestPath.to!string;
        auto id        = FlagId(extractIdFromPath(path));
        auto deletedBy = req.query.get("deletedBy", "");
        if (id.isNull) { writeError(res, 400, "Invalid flag ID"); return; }

        auto result = useCase.deleteFlag(tenantId, id, deletedBy);
        if (result.hasError) { writeError(res, 404, result.message); return; }

        res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
    }

    private:

    VariantDTO parseVariantDTO(Json v) {
        VariantDTO dto;
        dto.key         = getString(v, "key");
        dto.name        = getString(v, "name");
        dto.description = getString(v, "description");
        dto.value       = getString(v, "value");
        dto.weight      = getUint(v, "weight");
        return dto;
    }

    TargetingRuleDTO parseRuleDTO(Json r) {
        TargetingRuleDTO dto;
        dto.name        = getString(r, "name");
        dto.description = getString(r, "description");
        dto.type_       = getString(r, "type", "USER_MATCH");
        dto.variantKey  = getString(r, "variantKey");
        dto.priority    = getUint(r, "priority");
        dto.rolloutPercentage    = getUint(r, "rolloutPercentage");
        dto.targetIds            = getStringArray(r, "targetIds");
        dto.attributeConstraints = getStringMap(r, "attributeConstraints");
        return dto;
    }
}

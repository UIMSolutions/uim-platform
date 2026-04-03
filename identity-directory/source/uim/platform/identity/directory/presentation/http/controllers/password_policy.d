/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.http.password_policy;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import application.usecases.manage_password_policies;
import application.dto;
import domain.entities.password_policy;
import uim.platform.identity_authentication.presentation.http.json_utils;

/// HTTP controller for password policy management.
class PasswordPolicyController {
    private ManagePasswordPoliciesUseCase useCase;

    this(ManagePasswordPoliciesUseCase useCase) {
        this.useCase = useCase;
    }

    override void registerRoutes(URLRouter router) {
        router.post("/api/v1/password-policies", &handleCreate);
        router.get("/api/v1/password-policies", &handleList);
        router.get("/api/v1/password-policies/active", &handleGetActive);
        router.get("/api/v1/password-policies/*", &handleGet);
    }

    private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto j = req.json;
            auto createReq = CreatePasswordPolicyRequest(
                req.headers.get("X-Tenant-Id", ""),
                j.getString("name"),
                j.getString("description"),
                jsonUint(j, "minLength", 8),
                jsonUint(j, "maxLength", 128),
                j.getBoolean("requireUppercase", true),
                j.getBoolean("requireLowercase", true),
                j.getBoolean("requireDigit", true),
                j.getBoolean("requireSpecialChar"),
                jsonUint(j, "minUniqueChars"),
                jsonUint(j, "maxRepeatedChars"),
                jsonUint(j, "passwordHistoryCount", 5),
                jsonUint(j, "maxFailedAttempts", 5),
                jsonUint(j, "lockoutDurationMinutes", 30),
                jsonUint(j, "expiryDays"),
            );

            auto result = useCase.createPolicy(createReq);
            auto response = Json.emptyObject;

            if (result.isSuccess()) {
                response["policyId"] = Json(result.policyId);
                res.writeJsonBody(response, 201);
            } else {
                response["error"] = Json(result.error);
                res.writeJsonBody(response, 400);
            }
        } catch (Exception e) {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto policies = useCase.listPolicies(tenantId);
            auto response = Json.emptyObject;
            response["totalResults"] = Json(cast(long)policies.length);
            response["resources"] = toJsonArray(policies);
            res.writeJsonBody(response, 200);
        } catch (Exception e) {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleGetActive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto tenantId = req.headers.get("X-Tenant-Id", "");
            auto policy = useCase.getActivePolicy(tenantId);
            if (policy == PasswordPolicy.init) {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json("No active password policy found");
                res.writeJsonBody(errRes, 404);
                return;
            }
            res.writeJsonBody(toJsonValue(policy), 200);
        } catch (Exception e) {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }

    private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
            auto policyId = extractIdFromPath(req.requestURI);
            auto policy = useCase.getPolicy(policyId);
            if (policy == PasswordPolicy.init) {
                auto errRes = Json.emptyObject;
                errRes["error"] = Json("Password policy not found");
                res.writeJsonBody(errRes, 404);
                return;
            }
            res.writeJsonBody(toJsonValue(policy), 200);
        } catch (Exception e) {
            auto errRes = Json.emptyObject;
            errRes["error"] = Json("Internal server error");
            res.writeJsonBody(errRes, 500);
        }
    }
}

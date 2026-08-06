/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct AuthContext {
    int userId;
}

// Helper-Funktion für die Auth-Prüfung
AuthContext authenticate(HTTPServerRequest req, HTTPServerResponse res) {
    auto authHeader = req.headers.get("Authorization", "");
    if (authHeader != "SecretToken")
        throw new HTTPStatusException(HTTPStatus.unauthorized);
    return AuthContext(42);
}

void logResponse(HTTPServerRequest req, HTTPServerResponse res) @safe {
    if (res.statusCode >= 500) {
        // CRITICAL / SERVER FEHLER
        logError("HTTP 5xx Serverfehler auf %s %s (Status: %d)", req.method, req.path, res.statusCode);
    } else if (res.statusCode >= 400) {
        // WARNING / CLIENT FEHLER
        logWarn("HTTP 4xx Clientfehler auf %s %s (Status: %d)", req.method, req.path, res.statusCode);
    } else {
        // INFORMATIONS-MELDUNG (Standard)
        logInfo("HTTP Request erfolgreich: %s %s (Status: %d)", req.method, req.path, res.statusCode);
    }
}

interface IAppDefinitionApi {
    @headerParam("tenantId", "X-Tenant-Id")
    @before!authenticate("auth")
    // @after!logResponse
    @path("/") @method(HTTPMethod.GET)
    AppDefinition[] getAppDefinitions(string tenantId, AuthContext auth);

    @headerParam("tenantId", "X-Tenant-Id")
    @before!authenticate("auth")    
    // @after!logResponse
    @path("/:id") @method(HTTPMethod.GET)
    AppDefinition getAppDefinition(string tenantId, string _id, AuthContext auth);

    @headerParam("tenantId", "X-Tenant-Id")
    @before!authenticate("auth")
    // @after!logResponse
    @path("/") @method(HTTPMethod.POST)
    AppDefinitionResponse createAppDefinition(string tenantId, AppDefinitionDTO request, AuthContext auth);

    @headerParam("tenantId", "X-Tenant-Id")
    @before!authenticate("auth")
    // @after!logResponse
    @path("/:id") @method(HTTPMethod.PUT)
    void updateAppDefinition(string tenantId, string _id, AppDefinitionDTO request, AuthContext auth);

    @headerParam("tenantId", "X-Tenant-Id")
    @before!authenticate("auth")
    // @after!logResponse
    @path("/:id") @method(HTTPMethod.DELETE)
    void deleteAppDefinition(string tenantId, string _id, AuthContext auth);
}

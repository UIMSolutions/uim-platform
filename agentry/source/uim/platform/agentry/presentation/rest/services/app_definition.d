/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.services.app_definition;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

struct AppDefinitionRequest {
    string name;
    string version_;
    string description;
}

/// DTO für partielle Updates (PATCH)
struct AppDefinitionPatchRequest {
    Nullable!string name;
    Nullable!string version_;
    Nullable!string description;
}

/// DTO für die Antwort
struct AppDefinitionResponse {
    string tenantId;
    string id;
    string message;
    int code;
    // string description;
}

class AppDefinitionService : IAppDefinitionApi {
    private ManageAppDefinitionsUseCase usecase;

    this(ManageAppDefinitionsUseCase usecase) {
        this.usecase = usecase;
    }

    override AppDefinition[] getAppDefinitions(string tenantId, AuthContext auth) {
        return usecase.listDefinitions(TenantId(tenantId));
    }

    override AppDefinition getAppDefinition(string tenantId, string _id, AuthContext auth) {
        return usecase.getDefinition(TenantId(tenantId), AppDefinitionId(_id));
    }

    override AppDefinitionResponse createAppDefinition(string tenantId, AppDefinitionDTO request, AuthContext auth) {
        auto result = usecase.createDefinition(request);
        return AppDefinitionResponse(tenantId, result.id, result.message, result.code);
    }

    override void updateAppDefinition(string tenantId, string _id, AppDefinitionDTO request, AuthContext auth) {
        usecase.updateDefinition(request);
    }

    // @path("/:id") @method(HTTPMethod.PATCH)
    // AppDefinitionResponse patchApp(
    //     @headerParam("X-Tenant-ID") string tenantId,
    //     string _id,
    //     AppDefinitionPatchRequest req
    // );

    override void deleteAppDefinition(string tenantId, string _id, AuthContext auth) {
        usecase.deleteDefinition(TenantId(tenantId), AppDefinitionId(_id));
    }
}

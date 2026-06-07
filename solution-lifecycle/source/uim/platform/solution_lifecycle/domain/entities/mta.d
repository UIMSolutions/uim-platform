/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.entities.mta;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

/// A module within a deployed MTA — single application or service component.
struct MtaModule {
    string name;
    ModuleType moduleType;
    ModuleState state;
    string providedInterfaces; /// comma-separated provided service interfaces
    string[] urls;
}

/// A deployed MTA (Multi-Target Application) solution.
class Mta {
    mixin TenantEntity!(MtaId);

    string          mtaId;          /// MTA application ID from descriptor
    string          version_;       /// Deployed version
    string          description;
    SolutionType    solutionType;
    MtaStatus       status;
    string          archiveId;      /// Reference to source MtaArchive
    string          deployedBy;
    string          namespace_;
    string          spaceId;        /// Target Cloud Foundry space (CF mode) or subaccount
    string          extensionDescriptor; /// Optional applied extension YAML snippet
    MtaModule[]     modules;
    string[]        providedDependencies;
    string[]        requiredDependencies;
    string          lastOperationId; /// Most recent MtaOperation for this MTA
    long            completedAt;

    Json toJson() {
        auto j = Json.emptyObject;
        j["id"]              = id.value;
        j["tenantId"]        = tenantId;
        j["mtaId"]           = mtaId;
        j["version"]         = version_;
        j["description"]     = description;
        j["solutionType"]    = solutionType.to!string;
        j["status"]          = status.to!string;
        j["archiveId"]       = archiveId;
        j["deployedBy"]      = deployedBy;
        j["namespace"]       = namespace_;
        j["spaceId"]         = spaceId;
        j["lastOperationId"] = lastOperationId;
        j["completedAt"]     = completedAt;
        auto mods = Json.emptyArray;
        foreach (m; modules) {
            auto mj = Json.emptyObject;
            mj["name"]        = m.name;
            mj["moduleType"]  = m.moduleType.to!string;
            mj["state"]       = m.state.to!string;
            auto urls = Json.emptyArray;
            foreach (u; m.urls) urls ~= Json(u);
            mj["urls"] = urls;
            mods ~= mj;
        }
        j["modules"]  = mods;
        j["createdAt"] = createdAt;
        j["updatedAt"] = updatedAt;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}

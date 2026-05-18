/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.cli.models.workspace;

import uim.platform.workzone;

@safe:
/// CLI model for workspace operations — thin wrapper around the use case.
struct WorkspaceCliModel {
    private ManageWorkspacesUseCase _useCase;
    private string _tenantId;

    this(ManageWorkspacesUseCase useCase, string tenantId) {
        _useCase  = useCase;
        _tenantId = tenantId;
    }

    Workspace[] list() { return _useCase.listWorkspaces(_tenantId); }

    Workspace get(string id) {
        return _useCase.getWorkspace(_tenantId, WorkspaceId(id));
    }

    CommandResult create(string name, string description,
                         string alias_, string typeStr) {
        CreateWorkspaceRequest req;
        req.tenantId    = _tenantId;
        req.name        = name;
        req.description = description;
        req.alias_      = alias_;
        req.type        = parseType(typeStr);
        return _useCase.createWorkspace(req);
    }

    CommandResult remove(string id) {
        return _useCase.removeWorkspace(_tenantId, WorkspaceId(id));
    }

    private static WorkspaceType parseType(string s) @safe pure {
        switch (s) {
            case "project":    return WorkspaceType.project;
            case "department": return WorkspaceType.department;
            case "public":     return WorkspaceType.public_;
            case "external":   return WorkspaceType.external;
            default:           return WorkspaceType.team;
        }
    }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.models.workspace;

version (Have_gtkd) {
    import gobject.ObjectG : ObjectG;
    import gobject.Signals : Signals;
}

import uim.platform.workzone;

@safe:
/// Observable GUI model for the workspace list.
/// Wraps domain entities and fires a `changed` delegate when data mutates.
final class WorkspaceGuiModel {
    private Workspace[] _workspaces;
    private ManageWorkspacesUseCase _useCase;
    private string _tenantId;

    /// Fired after the workspace list is refreshed or mutated.
    void delegate() @safe onChanged;

    this(ManageWorkspacesUseCase useCase, TenantId tenantId) {
        _useCase  = useCase;
        _tenantId = tenantId;
    }

    // ── Read ──────────────────────────────────────────────────────────────
    @property const(Workspace[]) items() const { return _workspaces; }

    string nameAt(size_t index) const {
        return index < _workspaces.length ? _workspaces[index].name : "";
    }

    string idAt(size_t index) const {
        return index < _workspaces.length ? _workspaces[index].id.value : "";
    }

    size_t count() const { return _workspaces.length; }

    // ── Refresh from use case ──────────────────────────────────────────────
    void refresh() {
        _workspaces = _useCase.listWorkspaces(_tenantId);
        _notify();
    }

    // ── Mutations ─────────────────────────────────────────────────────────
    CommandResult createWorkspace(string name, string description,
                                  string alias_, WorkspaceType type) {
        CreateWorkspaceRequest req;
        req.tenantId    = _tenantId;
        req.name        = name;
        req.description = description;
        req.alias_      = alias_;
        req.type        = type;
        auto result = _useCase.createWorkspace(req);
        if (result.success) refresh();
        return result;
    }

    CommandResult removeWorkspace(string id) {
        auto result = _useCase.removeWorkspace(_tenantId, WorkspaceId(id));
        if (result.success) refresh();
        return result;
    }

    private void _notify() {
        if (onChanged !is null) onChanged();
    }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.gui.models.workpage;

import uim.platform.workzone;

@safe:
/// Observable GUI model for the workpage list under a single workspace.
final class WorkpageGuiModel {
    private Workpage[] _pages;
    private ManageWorkpagesUseCase _useCase;
    private string _tenantId;
    private string _workspaceId;

    void delegate() @safe onChanged;

    this(ManageWorkpagesUseCase useCase, TenantId tenantId, string workspaceId) {
        _useCase     = useCase;
        _tenantId    = tenantId;
        _workspaceId = workspaceId;
    }

    @property const(Workpage[]) items() const { return _pages; }
    @property string workspaceId() const      { return _workspaceId; }

    void setWorkspace(string workspaceId) {
        _workspaceId = workspaceId;
        refresh();
    }

    void refresh() {
        _pages = _useCase.listByWorkspace(_tenantId, WorkspaceId(_workspaceId));
        if (onChanged !is null) onChanged();
    }

    string titleAt(size_t i) const {
        return i < _pages.length ? _pages[i].title : "";
    }

    size_t count() const { return _pages.length; }
}

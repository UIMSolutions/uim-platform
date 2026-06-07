/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.models.workspace;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
/// Web view-model for a single workspace — pre-formatted for HTML rendering.
struct WorkspaceViewModel {
    string id;
    TenantId tenantId;
    string name;
    string description;
    string alias_;
    string typeLabel;
    string statusLabel;
    string statusCssClass;
    string imageUrl;
    size_t memberCount;
    size_t pageCount;
    string createdAtFormatted;

    /// Build from domain entity.
    static WorkspaceViewModel from(const Workspace ws) {
        WorkspaceViewModel vm;
        vm.id            = ws.id.value;
        vm.tenantId      = ws.tenantId;
        vm.name          = ws.name;
        vm.description   = ws.description;
        vm.alias_        = ws.alias_;
        vm.typeLabel     = labelForType(ws.type);
        vm.statusLabel   = labelForStatus(ws.status);
        vm.statusCssClass = cssForStatus(ws.status);
        vm.imageUrl      = ws.imageUrl;
        vm.memberCount   = ws.members.length;
        vm.pageCount     = ws.pageIds.length;
        vm.createdAtFormatted = formatTimestamp(ws.createdAt);
        return vm;
    }

    private static string labelForType(WorkspaceType t) {
        final switch (t) {
            case WorkspaceType.team:       return "Team";
            case WorkspaceType.project:    return "Project";
            case WorkspaceType.department: return "Department";
            case WorkspaceType.public_:    return "Public";
            case WorkspaceType.external:   return "External";
        }
    }

    private static string labelForStatus(WorkspaceStatus s) {
        final switch (s) {
            case WorkspaceStatus.active:   return "Active";
            case WorkspaceStatus.suspended:return "Suspended";
            case WorkspaceStatus.archived: return "Archived";
        }
    }

    private static string cssForStatus(WorkspaceStatus s) {
        final switch (s) {
            case WorkspaceStatus.active:   return "badge-success";
            case WorkspaceStatus.suspended:return "badge-warning";
            case WorkspaceStatus.archived: return "badge-secondary";
        }
    }
}

/// Lightweight list entry for workspace table rows.
struct WorkspaceListItem {
    string id;
    string name;
    string alias_;
    string typeLabel;
    string statusCssClass;
    string statusLabel;
    size_t memberCount;

    static WorkspaceListItem from(const Workspace ws) {
        return WorkspaceListItem(
            ws.id.value, ws.name, ws.alias_,
            WorkspaceViewModel.labelForType(ws.type),
            WorkspaceViewModel.cssForStatus(ws.status),
            WorkspaceViewModel.labelForStatus(ws.status),
            ws.members.length
        );
    }
}

/// View-model for the workspace list page.
struct WorkspaceListViewModel {
    TenantId tenantId;
    WorkspaceListItem[] items;
    string errorMessage;
    bool hasError() const { return errorMessage.length > 0; }
}

/// View-model for workspace detail / edit page.
struct WorkspaceDetailViewModel {
    WorkspaceViewModel workspace;
    string errorMessage;
    bool hasError() const { return errorMessage.length > 0; }
}

private string formatTimestamp(long ts) {
    import std.datetime : SysTime, unixTimeToStdTime;
    import std.format  : format;
    if (ts == 0) return "—";
    auto st = SysTime(unixTimeToStdTime(ts));
    return format!"%04d-%02d-%02d"(st.year, cast(int) st.month, st.day);
}

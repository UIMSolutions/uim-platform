/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.models.workpage;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
/// Web view-model for a workpage.
struct WorkpageViewModel {
    string id;
    string workspaceId;
    TenantId tenantId;
    string title;
    string description;
    int sortOrder;
    bool isDefault;
    bool visible;
    string visibilityLabel;

    static WorkpageViewModel from(const Workpage wp) {
        return WorkpageViewModel(
            wp.id.value,
            wp.workspaceId.value,
            wp.tenantId,
            wp.title,
            wp.description,
            wp.sortOrder,
            wp.isDefault,
            wp.visible,
            wp.visible ? "Visible" : "Hidden"
        );
    }
}

/// View-model for the workpage list page.
struct WorkpageListViewModel {
    string workspaceId;
    string workspaceName;
    WorkpageViewModel[] pages;
    string errorMessage;
    bool hasError() const { return errorMessage.length > 0; }
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.workpage;

import uim.platform.workzone.presentation.web.models.workpage;
import uim.platform.workzone.presentation.web.views.layout;
import std.array : appender;
import std.conv  : to;

@safe:
/// Render the workpage list for a workspace.
string renderWorkpageList(WorkpageListViewModel vm) {
    auto buf = appender!string;

    if (vm.hasError) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(vm.errorMessage) ~ `</div>`;
    }

    buf ~= `
<div class="d-flex justify-content-between align-items-center mb-3">
  <div>
    <a href="/ui/workspaces" class="text-decoration-none text-secondary small">&#8592; Workspaces</a>
    <h4 class="mb-0">` ~ escapeHtml(vm.workspaceName) ~ ` — Pages</h4>
  </div>
  <a href="/ui/workspaces/` ~ escapeHtml(vm.workspaceId) ~ `/pages/new" class="btn btn-primary btn-sm">+ New Page</a>
</div>
<div class="card shadow-sm">
  <div class="card-body p-0">
    <table class="table table-hover mb-0">
      <thead class="table-light">
        <tr><th>#</th><th>Title</th><th>Visibility</th><th>Default</th><th></th></tr>
      </thead>
      <tbody>`;

    if (vm.pages.length == 0) {
        buf ~= `<tr><td colspan="5" class="text-center text-muted py-4">No pages yet.</td></tr>`;
    }
    foreach (p; vm.pages) {
        buf ~= `<tr>
          <td>` ~ p.sortOrder.to!string ~ `</td>
          <td>` ~ escapeHtml(p.title) ~ `</td>
          <td>` ~ escapeHtml(p.visibilityLabel) ~ `</td>
          <td>` ~ (p.isDefault ? `<span class="badge bg-info">Default</span>` : ``) ~ `</td>
          <td>
            <a href="/ui/workspaces/` ~ escapeHtml(vm.workspaceId) ~ `/pages/` ~ escapeHtml(p.id) ~ `/edit"
               class="btn btn-outline-secondary btn-sm">Edit</a>
          </td>
        </tr>`;
    }

    buf ~= `
      </tbody>
    </table>
  </div>
</div>`;

    return renderLayout(vm.workspaceName ~ " — Pages", buf[], "workspaces");
}

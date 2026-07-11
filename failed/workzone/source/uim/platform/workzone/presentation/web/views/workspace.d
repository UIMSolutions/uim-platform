/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.workspace;

import uim.platform.workzone.presentation.web.models.workspace;
import uim.platform.workzone.presentation.web.views.layout;
import std.array : appender;
import std.conv  : to;

@safe:
/// Render the workspace list page.
string renderWorkspaceList(WorkspaceListViewModel vm) {
    auto buf = appender!string;

    if (vm.hasError) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(vm.errorMessage) ~ `</div>`;
    }

    buf ~= `
<div class="d-flex justify-content-between align-items-center mb-3">
  <h4 class="mb-0">Workspaces</h4>
  <a href="/ui/workspaces/new" class="btn btn-primary btn-sm">+ New Workspace</a>
</div>
<div class="card shadow-sm">
  <div class="card-body p-0">
    <table class="table table-hover mb-0">
      <thead class="table-light">
        <tr>
          <th>Name</th><th>Alias</th><th>Type</th>
          <th>Status</th><th>Members</th><th></th>
        </tr>
      </thead>
      <tbody>`;

    if (vm.items.length == 0) {
        buf ~= `<tr><td colspan="6" class="text-center text-muted py-4">No workspaces yet.</td></tr>`;
    }
    foreach (item; vm.items) {
        buf ~= `<tr>
          <td><a href="/ui/workspaces/` ~ escapeHtml(item.id) ~ `">` ~ escapeHtml(item.name) ~ `</a></td>
          <td><code>` ~ escapeHtml(item.alias_) ~ `</code></td>
          <td>` ~ escapeHtml(item.typeLabel) ~ `</td>
          <td><span class="badge ` ~ item.statusCssClass ~ `">` ~ escapeHtml(item.statusLabel) ~ `</span></td>
          <td>` ~ item.memberCount.to!string ~ `</td>
          <td>
            <a href="/ui/workspaces/` ~ escapeHtml(item.id) ~ `/edit" class="btn btn-outline-secondary btn-sm">Edit</a>
            <button class="btn btn-outline-danger btn-sm"
                    onclick="deleteWorkspace('` ~ escapeHtml(item.id) ~ `')">Delete</button>
          </td>
        </tr>`;
    }

    buf ~= `
      </tbody>
    </table>
  </div>
</div>
<script>
function deleteWorkspace(id) {
  if (!confirm("Delete workspace?")) return;
  fetch("/api/v1/workspaces/" + id, { method: "DELETE" })
    .then(() => location.reload());
}
</script>`;

    return renderLayout("Workspaces", buf[], "workspaces");
}

/// Render the workspace detail page.
string renderWorkspaceDetail(WorkspaceDetailViewModel vm) {
    auto buf = appender!string;
    const ws = vm.workspace;

    if (vm.hasError) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(vm.errorMessage) ~ `</div>`;
    }

    buf ~= `
<div class="d-flex justify-content-between align-items-center mb-3">
  <h4 class="mb-0">` ~ escapeHtml(ws.name) ~ `</h4>
  <div>
    <a href="/ui/workspaces/` ~ escapeHtml(ws.id) ~ `/pages" class="btn btn-outline-primary btn-sm me-2">Pages</a>
    <a href="/ui/workspaces/` ~ escapeHtml(ws.id) ~ `/edit" class="btn btn-outline-secondary btn-sm">Edit</a>
  </div>
</div>
<div class="row g-3">
  <div class="col-md-8">
    <div class="card shadow-sm">
      <div class="card-body">
        <p class="text-muted">` ~ escapeHtml(ws.description) ~ `</p>
        <dl class="row mb-0">
          <dt class="col-sm-3">Alias</dt>
          <dd class="col-sm-9"><code>` ~ escapeHtml(ws.alias_) ~ `</code></dd>
          <dt class="col-sm-3">Type</dt>
          <dd class="col-sm-9">` ~ escapeHtml(ws.typeLabel) ~ `</dd>
          <dt class="col-sm-3">Status</dt>
          <dd class="col-sm-9"><span class="badge ` ~ ws.statusCssClass ~ `">` ~ escapeHtml(ws.statusLabel) ~ `</span></dd>
          <dt class="col-sm-3">Created</dt>
          <dd class="col-sm-9">` ~ escapeHtml(ws.createdAtFormatted) ~ `</dd>
        </dl>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card shadow-sm">
      <div class="card-body text-center">
        <div class="fs-2 fw-bold">` ~ ws.memberCount.to!string ~ `</div>
        <div class="text-muted small">Members</div>
        <div class="fs-2 fw-bold mt-2">` ~ ws.pageCount.to!string ~ `</div>
        <div class="text-muted small">Pages</div>
      </div>
    </div>
  </div>
</div>`;

    return renderLayout(ws.name ~ " — Workspace", buf[], "workspaces");
}

/// Render the create / edit workspace form.
string renderWorkspaceForm(string workspaceId, string name, string description,
                           string alias_, string typeValue, string error) {
    immutable bool isNew = workspaceId.length == 0;
    immutable string action  = isNew ? "/api/v1/workspaces" : "/api/v1/workspaces/" ~ workspaceId;
    immutable string method  = isNew ? "POST" : "PUT";
    immutable string heading = isNew ? "New Workspace" : "Edit Workspace";

    auto buf = appender!string;
    if (error.length > 0) {
        buf ~= `<div class="alert alert-danger">` ~ escapeHtml(error) ~ `</div>`;
    }
    buf ~= `
<h4 class="mb-4">` ~ escapeHtml(heading) ~ `</h4>
<div class="card shadow-sm" style="max-width:600px">
  <div class="card-body">
    <form id="wsForm">
      <div class="mb-3">
        <label class="form-label">Name *</label>
        <input class="form-control" name="name" value="` ~ escapeHtml(name) ~ `" required>
      </div>
      <div class="mb-3">
        <label class="form-label">Description</label>
        <textarea class="form-control" name="description" rows="3">` ~ escapeHtml(description) ~ `</textarea>
      </div>
      <div class="mb-3">
        <label class="form-label">Alias (URL slug)</label>
        <input class="form-control" name="alias" value="` ~ escapeHtml(alias_) ~ `">
      </div>
      <div class="mb-3">
        <label class="form-label">Type</label>
        <select class="form-select" name="type">
          <option value="team"` ~ (typeValue == "team" ? " selected" : "") ~ `>Team</option>
          <option value="project"` ~ (typeValue == "project" ? " selected" : "") ~ `>Project</option>
          <option value="department"` ~ (typeValue == "department" ? " selected" : "") ~ `>Department</option>
          <option value="public"` ~ (typeValue == "public" ? " selected" : "") ~ `>Public</option>
          <option value="external"` ~ (typeValue == "external" ? " selected" : "") ~ `>External</option>
        </select>
      </div>
      <div class="d-flex gap-2">
        <button type="button" class="btn btn-primary" onclick="submitForm()">Save</button>
        <a href="/ui/workspaces" class="btn btn-outline-secondary">Cancel</a>
      </div>
    </form>
  </div>
</div>
<script>
function submitForm() {
  const f = document.getElementById("wsForm");
  const body = {
    name: f.name.value,
    description: f.description.value,
    alias: f.alias.value,
    type: f.type.value
  };
  fetch("` ~ action ~ `", {
    method: "` ~ method ~ `",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  }).then(r => r.json()).then(d => {
    if (d.success) location.href = "/ui/workspaces/" + d.id;
    else alert("Error: " + d.error);
  });
}
</script>`;

    return renderLayout(heading, buf[], "workspaces");
}

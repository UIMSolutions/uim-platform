/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.web.views.layout;

import std.array : appender;

@safe:
/// Shared HTML5 page layout used by all web views.
/// Wraps `bodyContent` in a fully-formed HTML document with navigation.
string renderLayout(string title, string bodyContent, string activeNav = "") {
    auto buf = appender!string;
    buf ~= `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>` ~ escapeHtml(title) ~ ` — SAP WorkZone</title>
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
        integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM"
        crossorigin="anonymous">
  <style>
    body { background: #f5f6fa; }
    .sidebar { min-height: 100vh; background: #1a2b4a; }
    .sidebar .nav-link { color: #bec8d9; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { color: #fff; background: #243654; }
    .topbar { background: #fff; border-bottom: 1px solid #dee2e6; }
    .badge-success  { background-color: #28a745 !important; }
    .badge-warning  { background-color: #ffc107 !important; color:#212529 !important; }
    .badge-secondary{ background-color: #6c757d !important; }
    .badge-primary  { background-color: #0d6efd !important; }
  </style>
</head>
<body>
<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <nav class="col-md-2 sidebar py-3 d-none d-md-block">
      <div class="text-white fw-bold px-3 mb-4" style="font-size:1.1rem">
        &#x25A3; SAP WorkZone
      </div>
      <ul class="nav flex-column">
        <li class="nav-item">
          <a class="nav-link` ~ (activeNav == "workspaces" ? " active" : "") ~ `"
             href="/ui/workspaces">Workspaces</a>
        </li>
        <li class="nav-item">
          <a class="nav-link` ~ (activeNav == "tasks" ? " active" : "") ~ `"
             href="/ui/tasks">My Tasks</a>
        </li>
        <li class="nav-item">
          <a class="nav-link` ~ (activeNav == "cards" ? " active" : "") ~ `"
             href="/ui/cards">Card Catalogue</a>
        </li>
        <li class="nav-item mt-3">
          <a class="nav-link" href="/api/v1/health">Health</a>
        </li>
      </ul>
    </nav>
    <!-- Main content -->
    <main class="col-md-10 p-4">
      <div class="topbar rounded p-2 mb-4 d-flex justify-content-between align-items-center">
        <span class="fw-semibold text-secondary">` ~ escapeHtml(title) ~ `</span>
      </div>
      ` ~ bodyContent ~ `
    </main>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz"
        crossorigin="anonymous"></script>
</body>
</html>`;
    return buf[];
}

/// Escape HTML special characters to prevent XSS.
string escapeHtml(string s) @safe pure {
    import std.array : replace;
    return s
        .replace("&",  "&amp;")
        .replace("<",  "&lt;")
        .replace(">",  "&gt;")
        .replace(`"`,  "&quot;")
        .replace("'",  "&#39;");
}

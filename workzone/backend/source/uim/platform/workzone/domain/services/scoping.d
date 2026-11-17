/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Generic accessors over the aggregates: display name and owning workspace.
module uim.platform.workzone.domain.services.scoping;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// The display name of an aggregate: name, title, display name or message.
string nameOf(TEntity)(const TEntity entity) {
  static if (__traits(hasMember, TEntity, "name"))
    return entity.name;
  else static if (__traits(hasMember, TEntity, "title"))
    return entity.title;
  else static if (__traits(hasMember, TEntity, "displayName"))
    return entity.displayName;
  else static if (__traits(hasMember, TEntity, "message"))
    return entity.message;
  else
    return entity.id.value;
}

/// The workspace an aggregate lives in (the workspace itself for Workspace).
WorkspaceId workspaceOf(TEntity)(const TEntity entity) {
  static if (is(TEntity == Workspace))
    return entity.id;
  else static if (__traits(hasMember, TEntity, "workspaceId"))
    return entity.workspaceId;
  else
    return WorkspaceId.init;
}

///
unittest {
  auto ws = Workspace(TenantId("t1"));
  ws.name = "Sales";
  auto page = Workpage(TenantId("t1"));
  page.title = "Home";
  page.workspaceId = ws.id;
  assert(nameOf(ws) == "Sales" && nameOf(page) == "Home");
  assert(workspaceOf(ws) == ws.id && workspaceOf(page) == ws.id);
  assert(workspaceOf(Card(TenantId("t1"))).isEmpty);
}

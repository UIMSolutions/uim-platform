/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Rules of the navigation tree of a site.
module uim.platform.workzone.domain.services.navigation;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// True if making `parent` the parent of `item` would create a cycle.
bool createsCycle(const NavigationItem[] items, NavigationItemId item, NavigationItemId parent) {
  NavigationItemId current = parent;
  foreach (_; 0 .. items.length + 1) {
    if (current.isEmpty)
      return false;
    if (current == item)
      return true;
    NavigationItemId next;
    foreach (i; items)
      if (i.id == current)
        next = i.parentId;
    current = next;
  }
  return true;
}

/// True if setting `parent` as parent tag of `tag` would create a cycle (by name).
bool createsTagCycle(const Tag[] tags, string tag, string parent) {
  string current = parent;
  foreach (_; 0 .. tags.length + 1) {
    if (current.length == 0)
      return false;
    if (current == tag)
      return true;
    string next;
    foreach (t; tags)
      if (t.name == current)
        next = t.parentTag;
    current = next;
  }
  return true;
}

/// The target fields an item type needs.
void validateNavigationTarget(const NavigationItem item) {
  final switch (item.itemType) {
  case NavigationItemType.link:
    validate(isLaunchTarget(item.targetUrl), "Link '" ~ item.title ~ "' needs a target URL (https://… or /path)");
    break;
  case NavigationItemType.externalLink:
    validate(isHttpUrl(item.targetUrl), "External link '" ~ item.title ~ "' needs an http(s) target URL");
    break;
  case NavigationItemType.app:
    validate(!item.targetAppId.isEmpty, "App entry '" ~ item.title ~ "' needs a targetAppId");
    break;
  case NavigationItemType.workpage:
    validate(!item.targetWorkpageId.isEmpty, "Workpage entry '" ~ item.title ~ "' needs a targetWorkpageId");
    break;
  case NavigationItemType.group, NavigationItemType.separator:
    break;
  }
}

///
unittest {
  NavigationItem a, b, c;
  a.id = NavigationItemId("a");
  b.id = NavigationItemId("b");
  b.parentId = a.id;
  c.id = NavigationItemId("c");
  c.parentId = b.id;
  auto items = [a, b, c];
  assert(createsCycle(items, a.id, c.id)); // a under c: c → b → a
  assert(!createsCycle(items, c.id, a.id));
  assert(createsCycle(items, a.id, a.id));

  Tag hr, payroll;
  hr.name = "HR";
  payroll.name = "Payroll";
  payroll.parentTag = "HR";
  assert(createsTagCycle([hr, payroll], "HR", "Payroll"));
  assert(!createsTagCycle([hr, payroll], "Payroll", "HR"));

  NavigationItem link;
  link.title = "Home";
  link.targetUrl = "/home";
  validateNavigationTarget(link);
}

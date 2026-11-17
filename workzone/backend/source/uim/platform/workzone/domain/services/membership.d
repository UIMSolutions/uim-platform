/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Workspace membership and access rules.
module uim.platform.workzone.domain.services.membership;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Index of a member (-1 if not a member).
ptrdiff_t memberIndex(const Workspace ws, string userId) {
  foreach (i, m; ws.members)
    if (m.userId == userId)
      return i;
  return -1;
}

bool isMember(const Workspace ws, string userId) {
  return memberIndex(ws, userId) >= 0;
}

/// True if the user holds at least `required` in the workspace.
bool hasRole(const Workspace ws, string userId, MemberRole required) {
  auto i = memberIndex(ws, userId);
  return i >= 0 && ws.members[i].role >= required;
}

size_t ownerCount(const Workspace ws) {
  return ws.members.count!(m => m.role == MemberRole.owner);
}

/// Validate and normalise the member list: user ids required and unique,
/// at least one owner. `creator` becomes owner if the list has none.
void normalizeMembers(ref Workspace ws, string creator, long now) {
  string[] seen;
  foreach (ref m; ws.members) {
    m.userId = m.userId.strip;
    validate(m.userId.length > 0, "Workspace members need a user ID");
    validate(!seen.canFind(m.userId), "User '" ~ m.userId ~ "' is listed twice as member");
    seen ~= m.userId;
    if (m.displayName.strip.length == 0)
      m.displayName = m.userId;
    if (m.joinedAt == 0)
      m.joinedAt = now;
  }
  if (ownerCount(ws) == 0 && creator.length > 0) {
    auto i = memberIndex(ws, creator);
    if (i >= 0)
      ws.members[i].role = MemberRole.owner;
    else
      ws.members ~= WorkspaceMember(creator, creator, MemberRole.owner, now);
  }
  validate(ownerCount(ws) > 0, "A workspace needs at least one owner");
}

/// Add a member (409 if already a member).
void admitMember(ref Workspace ws, WorkspaceMember member, long now) {
  validate(member.userId.strip.length > 0, "userId is required");
  ensureState(!isMember(ws, member.userId), "User '" ~ member.userId ~ "' is already a member of " ~ ws.name);
  if (member.displayName.length == 0)
    member.displayName = member.userId;
  member.joinedAt = now;
  ws.members ~= member;
}

/// Remove a member; the last owner cannot leave.
void dismissMember(ref Workspace ws, string userId) {
  auto i = memberIndex(ws, userId);
  ensureFound(i >= 0, "User '" ~ userId ~ "' is not a member of " ~ ws.name);
  ensureState(ws.members[i].role != MemberRole.owner || ownerCount(ws) > 1,
    "'" ~ userId ~ "' is the last owner of " ~ ws.name ~ " — make another member owner first");
  ws.members = ws.members[0 .. i] ~ ws.members[i + 1 .. $];
}

/// Change the role of a member; the last owner cannot be demoted.
void assignMemberRole(ref Workspace ws, string userId, MemberRole role) {
  auto i = memberIndex(ws, userId);
  ensureFound(i >= 0, "User '" ~ userId ~ "' is not a member of " ~ ws.name);
  ensureState(ws.members[i].role != MemberRole.owner || role == MemberRole.owner || ownerCount(ws) > 1,
    "'" ~ userId ~ "' is the last owner of " ~ ws.name);
  ws.members[i].role = role;
}

/// Content may only be added to active workspaces.
void ensureAcceptsContent(const Workspace ws, string what) {
  ensureState(ws.status == WorkspaceStatus.active, "Workspace '" ~ ws.name ~ "' is " ~ enumText(ws.status)
      ~ " — " ~ what ~ " cannot be added");
}

/// A workspace feature (forum, wiki, knowledge base, feeds) must be enabled.
void ensureFeature(bool enabled, const Workspace ws, string feature) {
  ensureState(enabled, "The " ~ feature ~ " is disabled in workspace '" ~ ws.name ~ "'");
}

///
unittest {
  bool failed(void delegate() @safe f) {
    try
      f();
    catch (WorkzoneException)
      return true;
    return false;
  }

  auto ws = Workspace(TenantId("t1"));
  ws.name = "Sales";
  normalizeMembers(ws, "jane", 1);
  assert(ws.members.length == 1 && ws.members[0].role == MemberRole.owner);
  admitMember(ws, WorkspaceMember("bob", "", MemberRole.viewer), 2);
  assert(hasRole(ws, "bob", MemberRole.viewer) && !hasRole(ws, "bob", MemberRole.admin));
  assert(failed(() => admitMember(ws, WorkspaceMember("bob"), 3)));
  assert(failed(() => dismissMember(ws, "jane"))); // last owner
  assert(failed(() => assignMemberRole(ws, "jane", MemberRole.admin)));
  assignMemberRole(ws, "bob", MemberRole.owner);
  dismissMember(ws, "jane");
  assert(!isMember(ws, "jane") && ownerCount(ws) == 1);

  auto dup = Workspace(TenantId("t1"));
  dup.members = [WorkspaceMember("a"), WorkspaceMember("a")];
  assert(failed(() => normalizeMembers(dup, "x", 1)));
  ws.status = WorkspaceStatus.archived;
  assert(failed(() => ensureAcceptsContent(ws, "pages")));
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving ports of spaces and their members.
module uim.platform.datasphere.ports.usecases.spaces;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

interface IManageSpaces : IManageResource!(Space, SpaceId, SpaceInput) {
  /// Lock the space: no runs, no new objects.
  Space lock(TenantId t, SpaceId id, string reason, UserId actor);
  Space unlock(TenantId t, SpaceId id, UserId actor);
  /// Recompute the used disk from the objects of the space.
  Space refreshUsage(TenantId t, SpaceId id);
}

interface IManageMembers : IManageResource!(SpaceMember, SpaceMemberId, MemberInput) {
}

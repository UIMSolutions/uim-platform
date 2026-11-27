/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Membership of a user in a space with a scoped role. One membership per
/// user and space.
module uim.platform.datasphere.domain.entities.space_member;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct SpaceMember {
  mixin TenantEntity!SpaceMemberId;

  SpaceId spaceId;
  string userName; /// user of the identity provider / built-in login
  string displayName;
  SpaceRole role = SpaceRole.viewer;

  void validate() const {
    requireId(id.value, "Member ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the member is required");
    requireId(userName, "User name");
    requireMaxLength(displayName, 200, "Display name");
  }
}

///
unittest {
  SpaceMember m;
  m.id = SpaceMemberId("m1");
  m.spaceId = SpaceId("SALES");
  m.userName = "ada";
  m.validate();
  m.userName = "a b";
  assert(failsWith(DspErrorKind.invalid, () { m.validate(); }));
}

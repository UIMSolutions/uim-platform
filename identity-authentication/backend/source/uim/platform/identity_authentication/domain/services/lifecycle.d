/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Lifecycle (status transition) rules of the identity directory.
module uim.platform.identity_authentication.domain.services.lifecycle;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// User statuses reachable from `from` (excluding staying in the same status).
UserStatus[] nextStatuses(UserStatus from) pure nothrow {
  final switch (from) with (UserStatus) {
  case pendingVerification:
    return [active, inactive];
  case active:
    return [locked, inactive];
  case locked:
    return [active, inactive];
  case inactive:
    return [active];
  }
}

/// True if a status change is allowed (staying in the same status always is).
bool canTransition(E)(E from, E to) if (is(E == enum)) {
  return from == to || nextStatuses(from).canFind(to);
}

/// Throws InvalidTransitionException if the change is not allowed.
void ensureTransition(E)(string entity, E from, E to) if (is(E == enum)) {
  if (!canTransition(from, to))
    throw new InvalidTransitionException(entity, enumValue(from), enumValue(to));
}
///
unittest {
  mixin(ShowTest!("lifecycle"));

  assert(canTransition(UserStatus.active, UserStatus.locked));
  assert(canTransition(UserStatus.locked, UserStatus.active));
  assert(!canTransition(UserStatus.inactive, UserStatus.locked));
  assert(!canTransition(UserStatus.active, UserStatus.pendingVerification));

  bool thrown;
  try
    ensureTransition("User", UserStatus.inactive, UserStatus.locked);
  catch (InvalidTransitionException e)
    thrown = e.from == "inactive" && e.to == "locked";
  assert(thrown);
}

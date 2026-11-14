/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.enumerations.binding;

import uim.platform.events;

mixin(ShowModule!());

@safe:

enum MessageBindingStatus : string {
  active = "active",
  inactive = "inactive"
}

enum MessageBindingPermission : string {
  publish = "publish",
  subscribe = "subscribe",
  publishSubscribe = "publishSubscribe",
  manage = "manage"
}

bool allowsPublish(MessageBindingPermission p) pure nothrow {
  return p == MessageBindingPermission.publish || p == MessageBindingPermission.publishSubscribe
    || p == MessageBindingPermission.manage;
}

bool allowsSubscribe(MessageBindingPermission p) pure nothrow {
  return p == MessageBindingPermission.subscribe || p == MessageBindingPermission.publishSubscribe
    || p == MessageBindingPermission.manage;
}

///
unittest {
  assert(allowsPublish(MessageBindingPermission.publishSubscribe) && !allowsPublish(MessageBindingPermission.subscribe));
  assert(allowsSubscribe(MessageBindingPermission.manage) && !allowsSubscribe(MessageBindingPermission.publish));
}

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain events ("block.created", "block.statusChanged", "relationship.created", ...).
module uim.platform.architecture.ports.messaging.events;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IArchitectureEventPublisher {
  /// type: e.g. "block.statusChanged"; subject: the block / relationship id.
  void publish(string type, TenantId t, string subject, Json data) nothrow;
}

/// Discards all events.
class NullEventPublisher : IArchitectureEventPublisher {
  void publish(string type, TenantId t, string subject, Json data) nothrow {
  }
}

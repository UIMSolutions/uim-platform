/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven port: publish authorization decisions (e.g. to an event broker or a SIEM).
module uim.platform.authorization.ports.messaging.decisions;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

interface IDecisionPublisher {
  void publish(const DecisionRecord decision);
}

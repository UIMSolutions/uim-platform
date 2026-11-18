/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.messaging.publisher;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Driven port: publishes domain events ("provisioning.job.completed",
/// "provisioning.system.activated", ...) to an event broker or the technical log.
interface IProvisioningEventPublisher {
  void publish(string topic, Json payload);
}

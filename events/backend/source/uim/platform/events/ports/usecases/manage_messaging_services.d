/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.ports.usecases.manage_messaging_services;

import uim.platform.events;

mixin(ShowModule!());

@safe:

interface IManageMessagingServices {
  MessagingService[] listMessagingServices(TenantId tenantId);
  MessagingService getMessagingService(TenantId tenantId, MessagingServiceId id);
  MessagingService createMessagingService(CreateMessagingServiceRequest request);
  MessagingService updateMessagingService(UpdateMessagingServiceRequest request);
  /// Refused while clients, queues or channels exist.
  void deleteMessagingService(TenantId tenantId, MessagingServiceId id);
}

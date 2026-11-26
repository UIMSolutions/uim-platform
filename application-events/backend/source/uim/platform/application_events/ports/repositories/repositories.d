/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.application_events.ports.repositories.repositories;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

interface IFormationRepository : IAehRepository!(Formation, FormationId) {
}

interface ISystemRepository : IAehRepository!(SystemRegistration, SystemRegistrationId) {
}

interface ITopicRepository : IAehRepository!(EventTopic, EventTopicId) {
}

interface IChannelRepository : IAehRepository!(EventChannel, EventChannelId) {
}

interface ISubscriptionRepository : IAehRepository!(EventSubscription, EventSubscriptionId) {
}

interface IFilterRepository : IAehRepository!(EventFilter, EventFilterId) {
}

interface IMessageRepository : IAehRepository!(EventMessage, EventMessageId) {
  /// Messages in one of the states (cheap pre-filter on the record).
  EventMessage[] findByStatus(TenantId t, const MessageStatus[] statuses);
}

interface IDeadLetterRepository : IAehRepository!(DeadLetterEntry, DeadLetterEntryId) {
}

interface IUserAccountRepository : IAehRepository!(UserAccount, UserAccountId) {
}

/// All repositories (passed to the interactors as one bundle).
struct AehRepositories {
  IFormationRepository formations;
  ISystemRepository systems;
  ITopicRepository topics;
  IChannelRepository channels;
  ISubscriptionRepository subscriptions;
  IFilterRepository filters;
  IMessageRepository messages;
  IDeadLetterRepository deadLetters;
  IUserAccountRepository users;
}

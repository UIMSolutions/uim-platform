/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.application_events.persistence.repositories.repositories;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

class FormationRepository : DocumentRepository!(Formation, FormationId), IFormationRepository {
  this(IDocumentStore store) {
    super(store, Collections.formations);
  }
}

class SystemRepository : DocumentRepository!(SystemRegistration, SystemRegistrationId), ISystemRepository {
  this(IDocumentStore store) {
    super(store, Collections.systems);
  }
}

class TopicRepository : DocumentRepository!(EventTopic, EventTopicId), ITopicRepository {
  this(IDocumentStore store) {
    super(store, Collections.topics);
  }
}

class ChannelRepository : DocumentRepository!(EventChannel, EventChannelId), IChannelRepository {
  this(IDocumentStore store) {
    super(store, Collections.channels);
  }
}

class SubscriptionRepository : DocumentRepository!(EventSubscription, EventSubscriptionId), ISubscriptionRepository {
  this(IDocumentStore store) {
    super(store, Collections.subscriptions);
  }
}

class FilterRepository : DocumentRepository!(EventFilter, EventFilterId), IFilterRepository {
  this(IDocumentStore store) {
    super(store, Collections.filters);
  }
}

class MessageRepository : DocumentRepository!(EventMessage, EventMessageId), IMessageRepository {
  this(IDocumentStore store) {
    super(store, Collections.messages);
  }

  EventMessage[] findByStatus(TenantId t, const MessageStatus[] statuses) {
    Json[] docs;
    foreach (doc; store.all(collection, t.value)) {
      auto s = textField(doc, "status");
      foreach (wanted; statuses)
        if (s == cast(string) wanted) {
          docs ~= doc;
          break;
        }
    }
    return mapped(docs);
  }
}

class DeadLetterRepository : DocumentRepository!(DeadLetterEntry, DeadLetterEntryId), IDeadLetterRepository {
  this(IDocumentStore store) {
    super(store, Collections.deadLetters);
  }
}

class UserAccountRepository : DocumentRepository!(UserAccount, UserAccountId), IUserAccountRepository {
  this(IDocumentStore store) {
    super(store, Collections.users);
  }
}

/// All repositories over one document store.
AehRepositories createRepositories(IDocumentStore store) {
  AehRepositories r;
  r.formations = new FormationRepository(store);
  r.systems = new SystemRepository(store);
  r.topics = new TopicRepository(store);
  r.channels = new ChannelRepository(store);
  r.subscriptions = new SubscriptionRepository(store);
  r.filters = new FilterRepository(store);
  r.messages = new MessageRepository(store);
  r.deadLetters = new DeadLetterRepository(store);
  r.users = new UserAccountRepository(store);
  return r;
}

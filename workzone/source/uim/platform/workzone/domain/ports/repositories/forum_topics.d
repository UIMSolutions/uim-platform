/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.forum_topics;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.forum_topic;

interface ForumTopicRepository {
  ForumTopic[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId);
  ForumTopic* findById(ForumTopicId tenantId, id tenantId);
  ForumTopic[] findByAuthor(UserId authortenantId, id tenantId);
  ForumTopic[] findByTenant(TenantId tenantId);
  void save(ForumTopic topic);
  void update(ForumTopic topic);
  void remove(ForumTopicId tenantId, id tenantId);
}

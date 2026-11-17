/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.services.statistics;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Application service: aggregated figures of a tenant.
class WorkzoneStatisticsService : IWorkzoneStatisticsService {
  protected WorkzoneRepositories repos;

  this(WorkzoneRepositories repos) {
    this.repos = repos;
  }

  WorkzoneStatistics statistics(TenantId tenantId) {
    WorkzoneStatistics s;
    s.tenantId = tenantId;
    auto now = nowStdTime();
    int pending;
    int n(R)(R repo) {
      return cast(int) repo.findByTenant(tenantId).length;
    }

    foreach (w; repos.workspaces.findByTenant(tenantId)) {
      s.workspaces++;
      if (w.status == WorkspaceStatus.active)
        s.workspacesActive++;
      s.members += cast(int) w.members.length;
    }
    s.workpages = n(repos.workpages);
    s.widgets = n(repos.widgets);
    s.channels = n(repos.channels);
    foreach (c; repos.content.findByTenant(tenantId)) {
      s.contentItems++;
      if (c.status == ContentStatus.published)
        s.contentPublished++;
      s.lastPublishedAt = max(s.lastPublishedAt, c.publishedAt);
    }
    s.feedEntries = n(repos.feedEntries);
    foreach (e; repos.events.findByTenant(tenantId)) {
      if (e.status == EventStatus.scheduled)
        s.eventsUpcoming++;
      if (eventStatusAt(e, now) != e.status)
        pending++;
    }
    foreach (v; repos.surveys.findByTenant(tenantId)) {
      if (v.status == SurveyStatus.active)
        s.surveysActive++;
      if (isExpired(v, now))
        pending++;
    }
    s.forumTopicsOpen = cast(int) repos.forumTopics.findMatching(tenantId,
      (const ForumTopic t) => t.status == ForumTopicStatus.open).length;
    foreach (a; repos.knowledgeBase.findByTenant(tenantId)) {
      if (a.status == KBArticleStatus.published)
        s.articlesPublished++;
      s.lastPublishedAt = max(s.lastPublishedAt, a.publishedAt);
    }
    foreach (t; repos.tasks.findByTenant(tenantId)) {
      if (t.status.isPending)
        s.tasksOpen++;
      if (t.status == TaskStatus.overdue)
        s.tasksOverdue++;
      if (isOverdue(t, now))
        pending++;
    }
    foreach (x; repos.notifications.findByTenant(tenantId)) {
      if (x.status == NotificationStatus.unread || x.status == NotificationStatus.actionRequired)
        s.notificationsUnread++;
      if (isExpired(x, now))
        pending++;
    }
    s.cards = n(repos.cards);
    foreach (a; repos.apps.findByTenant(tenantId)) {
      s.apps++;
      if (a.status == AppStatus.active)
        s.appsActive++;
    }
    foreach (p; repos.contentProviders.findByTenant(tenantId)) {
      if (p.status == ProviderStatus.connected)
        s.providersConnected++;
      if (isDueForSync(p, now))
        pending++;
    }
    s.shellPluginsActive = cast(int) repos.shellPlugins.findMatching(tenantId,
      (const ShellPlugin p) => p.status == PluginStatus.active).length;
    foreach (x; repos.sites.findByTenant(tenantId)) {
      s.sites++;
      if (x.status == SiteStatus.published)
        s.sitesPublished++;
    }
    s.users = n(repos.userProfiles);
    s.roles = n(repos.roles);
    s.groups = n(repos.groups);
    s.pendingHousekeeping = pending;
    return s;
  }
}

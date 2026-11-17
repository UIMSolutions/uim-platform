/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.surveys;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: surveys. Questions can only change in draft; activation needs
/// answerable questions; responses are counted once per user unless allowed.
class ManageSurveysUseCase
  : ResourceUseCase!(Survey, SurveyId, CreateSurveyRequest, UpdateSurveyRequest),
  IManageSurveysUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.surveys, publisher, "Survey", "workzone.survey");
    this.feed = feed;
  }

  override protected Survey build(CreateSurveyRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "surveys");
    auto s = Survey(r.tenantId);
    s.workspaceId = ws.id;
    s.workspaceName = ws.name;
    s.creatorId = r.actor;
    assignMatching(s, r.spec);
    if (s.creatorName.strip.length == 0)
      s.creatorName = feed.displayNameOf(r.tenantId, r.actor);
    check(s);
    return s;
  }

  override protected void apply(ref Survey s, SurveySpec spec) {
    ensureState(s.status == SurveyStatus.draft, "Survey '" ~ s.title ~ "' is " ~ enumText(s.status)
        ~ " — only drafts can be changed");
    assignMatching(s, spec);
    check(s);
  }

  protected static void check(ref Survey s) {
    s.title = s.title.strip;
    validateDisplayName("Survey title", s.title, 200);
    validate(s.endsAt == 0 || s.endsAt > s.startsAt, "A survey must end after it starts");
    foreach (i, ref q; s.questions) {
      if (q.questionId.strip.length == 0)
        q.questionId = "q" ~ (i + 1).to!string;
      q.options = normalizedNames(q.options);
      if (q.sortOrder == 0)
        q.sortOrder = cast(int) i + 1;
    }
  }

  UsecaseResult activate(TenantId tenantId, SurveyId id, UserId actor) {
    return transition(tenantId, id, actor, "activated", (ref Survey s) {
      ensureState(s.status == SurveyStatus.draft, "Only draft surveys can be activated");
      requireWorkspace(tenantId, s.workspaceId, "surveys");
      validateQuestions(s);
      auto now = nowStdTime();
      ensureState(s.endsAt == 0 || s.endsAt > now, "The end date of survey '" ~ s.title ~ "' has passed");
      if (s.startsAt == 0)
        s.startsAt = now;
      s.status = SurveyStatus.active;
    });
  }

  UsecaseResult close(TenantId tenantId, SurveyId id, UserId actor) {
    return transition(tenantId, id, actor, "closed", (ref Survey s) {
      ensureState(s.status == SurveyStatus.active, "Only active surveys can be closed");
      s.status = SurveyStatus.closed;
      s.endsAt = nowStdTime();
    });
  }

  UsecaseResult archive(TenantId tenantId, SurveyId id, UserId actor) {
    return transition(tenantId, id, actor, "archived", (ref Survey s) {
      ensureState(s.status == SurveyStatus.closed || s.status == SurveyStatus.draft,
        "Close survey '" ~ s.title ~ "' before archiving it");
      s.status = SurveyStatus.archived;
    });
  }

  UsecaseResult respond(TenantId tenantId, SurveyId id, UserId actor) {
    return transition(tenantId, id, actor, "answered", (ref Survey s) {
      ensureState(s.status == SurveyStatus.active, "Survey '" ~ s.title ~ "' is not active");
      auto who = actor.value;
      if (!s.allowMultipleResponses && who.length > 0)
        ensureState(!s.respondents.canFind(who), "'" ~ who ~ "' has already answered survey " ~ s.title);
      // respondents only back the single response rule; answers are never linked to them
      if (who.length > 0 && !s.respondents.canFind(who))
        s.respondents ~= who;
      s.responseCount++;
    });
  }
}

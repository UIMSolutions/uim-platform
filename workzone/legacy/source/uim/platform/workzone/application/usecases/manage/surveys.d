/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.surveys;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.survey;
// import uim.platform.workzone.domain.ports.repositories.surveys;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageSurveysUseCase {
  protected ISurveyRepository repo;

  this(ISurveyRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createSurvey(CreateSurveyRequest req) {
    if (req.title.length == 0)
      return UsecaseResult(false, "", "Survey title is required");

    auto s = Survey(req.tenantId);
    s.workspaceId = req.workspaceId;
    s.title = req.title;
    s.description = req.description;
    s.creatorId = req.creatorId;
    s.creatorName = req.creatorName;
    s.status = SurveyStatus.draft;
    s.questions = req.questions;
    s.anonymous = req.anonymous;
    s.allowMultipleResponses = req.allowMultipleResponses;
    s.startsAt = req.startsAt;
    s.endsAt = req.endsAt;

    repo.save(s);
    return UsecaseResult(true, s.id.value, "");
  }

  Survey getSurvey(TenantId tenantId, SurveyId id) {
    return repo.findById(tenantId, id);
  }

  Survey[] listSurveys(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  UsecaseResult updateSurvey(UpdateSurveyRequest req) {
    auto s = repo.findById(req.tenantId, req.id);
    if (s.isNull)
      return UsecaseResult(false, "", "Survey not found");

    if (req.title.length > 0)
      s.title = req.title;
    if (req.description.length > 0)
      s.description = req.description;
    // TODO: s.status = req.status;
    s.updatedAt = currentTimestamp();

    repo.update(s);
    return UsecaseResult(true, s.id.value, "");
  }

  UsecaseResult deleteSurvey(TenantId tenantId, SurveyId id) {
    auto s = repo.findById(tenantId, id);
    if (s.isNull)
      return UsecaseResult(false, "", "Survey not found");

    repo.remove(s);
    return UsecaseResult(true, s.id.value, "");
  }
}

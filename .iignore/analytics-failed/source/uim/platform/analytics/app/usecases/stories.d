/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.stories;
// import uim.platform.analytics.domain.entities.story;
// import uim.platform.analytics.domain.repositories.story;

// import uim.platform.analytics.app.dto.story;
import uim.platform.analytics;

mixin(ShowModule!());

@safe:
class StoryUseCases {
  private StoryRepository repo;

  this(StoryRepository repo) {
    this.repo = repo;
  }

  StoryResponse createStory(TenantId tenantId, CreateStoryRequest req) {
    auto story = Story(tenantId);
    story.title = req.title;
    story.description = req.description;
    story.ownerId = req.ownerId;
    
    repo.save(story);
    return StoryResponse.fromEntity(story);
  }

  StoryResponse getStory(TenantId tenantId, StoryId id) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == id).array;
    return StoryResponse.fromEntity(found.empty ? Story.init : found[0]);
  }

  StoryResponse[] listStories(TenantId tenantId) {
    StoryResponse[] result;
    foreach (s; repo.findByTenant(tenantId))
      result ~= StoryResponse.fromEntity(s);
    return result;
  }

  StoryResponse addSectionToStory(TenantId tenantId, StoryId storyId, string heading, string narrative) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == storyId).array;
    auto s = found.empty ? Story.init : found[0];
    if (s.isNull)
      return StoryResponse.init;
    s.addSection(heading, narrative);
    repo.save(s);
    return StoryResponse.fromEntity(s);
  }

  StoryResponse publishStory(TenantId tenantId, StoryId storyId) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == storyId).array;
    auto s = found.empty ? Story.init : found[0];
    if (s.isNull)
      return StoryResponse.init;
    s.publish();
    repo.save(s);
    return StoryResponse.fromEntity(s);
  }

  CommandResult deleteStory(TenantId tenantId, StoryId storyId) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id == storyId).array;
    auto s = found.empty ? Story.init : found[0];
    if (s.isNull)
      return CommandResult(false, "", "Story not found");

    repo.remove(s);
    return CommandResult(true, s.id.value, "");
  }
}

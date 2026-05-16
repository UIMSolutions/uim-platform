/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.stories;
// import uim.platform.analytics.domain.entities.story;
// import uim.platform.analytics.domain.repositories.story;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.app.dto.story;
import uim.platform.analytics;

mixin(ShowModule!());

@safe:
class StoryUseCases {
  private StoryRepository repo;

  this(StoryRepository repo) {
    this.repo = repo;
  }

  StoryResponse createStory(CreateStoryRequest req) {
    auto story = Story.create(req.title, req.description, req.ownerId);
    repo.save(story);
    return StoryResponse.fromEntity(story);
  }

  StoryResponse getStory(string id) {
    return StoryResponse.fromEntity(repo.findById(EntityId(id)));
  }

  StoryResponse[] listStories() {
    StoryResponse[] result;
    foreach (s; repo.findAll())
      result ~= StoryResponse.fromEntity(s);
    return result;
  }

  StoryResponse addSectionToStory(string storyId, string heading, string narrative) {
    auto s = repo.findById(EntityId(storyId));
    if (s.isNull)
      return StoryResponse.init;
    s.addSection(heading, narrative);
    repo.save(s);
    return StoryResponse.fromEntity(s);
  }

  StoryResponse publishStory(string storyId) {
    auto s = repo.findById(EntityId(storyId));
    if (s.isNull)
      return StoryResponse.init;
    s.publish();
    repo.save(s);
    return StoryResponse.fromEntity(s);
  }

  CommandResult deleteStory(string storyId) {
    auto s = repo.findById(EntityId(storyId));
    if (s.isNull)
      return CommandResult(false, "", "Story not found");

    repo.remove(s);
    return CommandResult(true, s.id.value, "");
  }
}

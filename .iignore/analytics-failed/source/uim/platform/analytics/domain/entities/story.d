/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.story;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// A Story is a narrative-driven analytical report (SAC "Story" mode).
/// Contains sections with embedded visualizations, text, and images.
struct Story {
  mixin TenantEntity!StoryId;
  ResourceGroupId resourceGroupId;

  string title;
  string description;
  EntityId ownerId;
  Visibility visibility;
  ArtifactStatus status;
  Section[] sections;
  AuditInfo audit;
  string[] tags;

  // this() {
  // }

  static Story create(string title, string description, string ownerId) {
    Story s;
    s.id = StoryId(EntityId.generate().value);
    s.title = title;
    s.description = description;
    s.ownerId = EntityId(ownerId);
    s.visibility = Visibility.Private;
    s.status = ArtifactStatus.Draft;
    return s;
  }

  void addSection(string heading, string narrative) {
    Section s;
    s.id = SectionId(EntityId.generate().value);
    s.heading = heading;
    s.narrative = narrative;
    sections ~= s;
  }

  void publish() {
    status = ArtifactStatus.Published;
  }

  void archive() {
    status = ArtifactStatus.Archived;
  }
}
/// A section within a story, mixing text and widget references.
struct Section {
  mixin IdEntity!SectionId;
  
  string heading;
  string narrative;
  EntityId[] widgetIds;
}

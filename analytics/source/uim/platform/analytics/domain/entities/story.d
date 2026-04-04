/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.story;

import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

/// A Story is a narrative-driven analytical report (SAC "Story" mode).
/// Contains sections with embedded visualizations, text, and images.
class Story {
  EntityId id;
  string title;
  string description;
  EntityId ownerId;
  Visibility visibility;
  ArtifactStatus status;
  Section[] sections;
  AuditInfo audit;
  string[] tags;

  this()
  {
  }

  static Story create(string title, string description, string ownerId)
  {
    auto s = new Story();
    s.id = EntityId.generate();
    s.title = title;
    s.description = description;
    s.ownerId = EntityId(ownerId);
    s.visibility = Visibility.Private;
    s.status = ArtifactStatus.Draft;
    s.sections = [];
    s.tags = [];
    s.audit = AuditInfo.create(ownerId);
    return s;
  }

  void addSection(string heading, string narrative)
  {
    sections ~= Section(EntityId.generate(), heading, narrative, []);
  }

  void publish()
  {
    status = ArtifactStatus.Published;
  }

  void archive()
  {
    status = ArtifactStatus.Archived;
  }
}

/// A section within a story, mixing text and widget references.
struct Section {
  EntityId id;
  string heading;
  string narrative;
  EntityId[] widgetIds;
}

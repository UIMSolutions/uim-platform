/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.events;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Interactor: calendar events. The time window is validated; scheduled →
/// ongoing → completed is driven by housekeeping.
class ManageEventsUseCase
  : ResourceUseCase!(CalendarEvent, EventId, CreateEventRequest, UpdateEventRequest),
  IManageEventsUseCase {

  protected FeedRecorder feed;

  this(WorkzoneRepositories repos, FeedRecorder feed, IWorkzoneEventPublisher publisher) {
    super(repos, repos.events, publisher, "Event", "workzone.event");
    this.feed = feed;
  }

  override protected CalendarEvent build(CreateEventRequest r) {
    auto ws = requireWorkspace(r.tenantId, r.parentId, "events");
    auto e = CalendarEvent(r.tenantId);
    e.workspaceId = ws.id;
    e.workspaceName = ws.name;
    e.organizerId = r.actor;
    assignMatching(e, r.spec);
    if (e.organizerName.strip.length == 0)
      e.organizerName = feed.displayNameOf(r.tenantId, r.actor);
    check(e);
    e.status = eventStatusAt(e, nowStdTime());
    return e;
  }

  override protected void afterCreate(CalendarEvent e, UserId actor) {
    feed.record(e.tenantId, e.workspaceId, actor, "scheduled", "event", e.id.value, e.title);
  }

  override protected void apply(ref CalendarEvent e, EventSpec spec) {
    ensureState(e.status != EventStatus.cancelled && e.status != EventStatus.completed,
      "Event '" ~ e.title ~ "' is " ~ enumText(e.status) ~ " and cannot be changed");
    assignMatching(e, spec);
    check(e);
    e.status = eventStatusAt(e, nowStdTime());
  }

  protected static void check(ref CalendarEvent e) {
    e.title = e.title.strip;
    validateDisplayName("Event title", e.title, 200);
    validateEventWindow(e);
    validateOptionalUrl("Meeting URL", e.meetingUrl);
    e.attendeeIds = normalizedNames(e.attendeeIds);
  }

  UsecaseResult cancel(TenantId tenantId, EventId id, UserId actor) {
    return transition(tenantId, id, actor, "cancelled", (ref CalendarEvent e) {
      ensureState(e.status == EventStatus.scheduled || e.status == EventStatus.ongoing,
        "Event '" ~ e.title ~ "' is already " ~ enumText(e.status));
      e.status = EventStatus.cancelled;
    });
  }

  UsecaseResult addAttendee(TenantId tenantId, EventId id, string userId, UserId actor) {
    return transition(tenantId, id, actor, "attendee added", (ref CalendarEvent e) {
      validate(userId.strip.length > 0, "userId is required");
      ensureState(e.status == EventStatus.scheduled, "Attendees can only be added to scheduled events");
      ensureState(!e.attendeeIds.canFind(userId), "'" ~ userId ~ "' already attends " ~ e.title);
      e.attendeeIds ~= userId.strip;
    });
  }

  UsecaseResult removeAttendee(TenantId tenantId, EventId id, string userId, UserId actor) {
    return transition(tenantId, id, actor, "attendee removed", (ref CalendarEvent e) {
      ensureFound(e.attendeeIds.canFind(userId), "'" ~ userId ~ "' does not attend " ~ e.title);
      e.attendeeIds = e.attendeeIds.filter!(a => a != userId).array;
    });
  }
}

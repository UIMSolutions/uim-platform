/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time driven lifecycle rules (applied by housekeeping).
module uim.platform.workzone.domain.services.schedule;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A pending task whose due date has passed becomes overdue.
bool isOverdue(const WorkTask task, long now) {
  return task.dueAt > 0 && now > task.dueAt && (task.status == TaskStatus.open || task.status == TaskStatus.inProgress);
}

/// The status an event should have at `now` (cancelled and completed are final).
EventStatus eventStatusAt(const CalendarEvent ev, long now) {
  if (ev.status == EventStatus.cancelled || ev.status == EventStatus.completed)
    return ev.status;
  if (ev.endsAt > 0 && now >= ev.endsAt)
    return EventStatus.completed;
  if (ev.startsAt > 0 && now >= ev.startsAt)
    return EventStatus.ongoing;
  return EventStatus.scheduled;
}

/// Validate the time window of an event; all-day events span whole days.
void validateEventWindow(ref CalendarEvent ev) {
  validate(ev.startsAt > 0, "Start time is required");
  if (ev.allDay) {
    ev.startsAt = ev.startsAt - ev.startsAt % stdTimeDay;
    if (ev.endsAt <= ev.startsAt)
      ev.endsAt = ev.startsAt + stdTimeDay;
  }
  if (ev.endsAt == 0)
    ev.endsAt = ev.startsAt + stdTimeDay / 24; // default: one hour
  validate(ev.endsAt > ev.startsAt, "An event must end after it starts");
}

/// An active survey past its end date is closed.
bool isExpired(const Survey s, long now) {
  return s.status == SurveyStatus.active && s.endsAt > 0 && now >= s.endsAt;
}

/// A notification past its expiry is dismissed.
bool isExpired(const Notification n, long now) {
  return n.status != NotificationStatus.dismissed && n.expiresAt > 0 && now >= n.expiresAt;
}

/// A connected provider whose refresh interval elapsed needs a sync.
bool isDueForSync(const ExternalContentProvider p, long now) {
  enum long second = 10_000_000L;
  return p.status == ProviderStatus.connected && p.refreshIntervalSec > 0
    && now - p.lastSyncAt >= p.refreshIntervalSec * second;
}

/// Questions must be answerable before a survey is activated.
void validateQuestions(const Survey s) {
  validate(s.questions.length > 0, "Survey '" ~ s.title ~ "' has no questions");
  string[] ids;
  foreach (q; s.questions) {
    validate(q.text.strip.length > 0, "Survey questions need a text");
    validate(q.questionId.length == 0 || !ids.canFind(q.questionId), "Question ID '" ~ q.questionId ~ "' is used twice");
    ids ~= q.questionId;
    if (q.questionType.needsOptions)
      validate(normalizedNames(q.options).length >= 2, "Question '" ~ q.text ~ "' needs at least two options");
  }
}

///
unittest {
  auto t = WorkTask(TenantId("t1"));
  t.dueAt = 100;
  assert(isOverdue(t, 101) && !isOverdue(t, 99));
  t.status = TaskStatus.completed;
  assert(!isOverdue(t, 101));

  CalendarEvent ev;
  ev.startsAt = 100;
  ev.endsAt = 200;
  assert(eventStatusAt(ev, 50) == EventStatus.scheduled);
  assert(eventStatusAt(ev, 150) == EventStatus.ongoing);
  assert(eventStatusAt(ev, 250) == EventStatus.completed);
  ev.status = EventStatus.cancelled;
  assert(eventStatusAt(ev, 150) == EventStatus.cancelled);

  CalendarEvent day;
  day.allDay = true;
  day.startsAt = stdTimeDay * 3 + 5;
  validateEventWindow(day);
  assert(day.startsAt == stdTimeDay * 3 && day.endsAt == stdTimeDay * 4);

  Survey s;
  s.title = "Pulse";
  s.questions = [SurveyQuestion("q1", "Happy?", QuestionType.singleChoice, ["yes"])];
  bool failed;
  try validateQuestions(s);
  catch (WorkzoneException) failed = true;
  assert(failed);
  s.questions[0].options ~= "no";
  validateQuestions(s);

  ExternalContentProvider p;
  p.status = ProviderStatus.connected;
  p.refreshIntervalSec = 1;
  assert(isDueForSync(p, 10_000_000L) && !isDueForSync(p, 1));
}

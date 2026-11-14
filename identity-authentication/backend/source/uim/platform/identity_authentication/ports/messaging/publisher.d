/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.ports.messaging.publisher;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Topics of the identity authentication domain events (audit trail).
enum IdentityTopics : string {
  loginSucceeded = "ias.login.succeeded",
  loginFailed = "ias.login.failed",
  logout = "ias.logout",
  userCreated = "ias.user.created",
  userStatusChanged = "ias.user.status-changed",
  userLocked = "ias.user.locked",
  passwordChanged = "ias.user.password-changed",
  mfaEnrolled = "ias.user.mfa-enrolled",
  mfaDisabled = "ias.user.mfa-disabled",
  tokensIssued = "ias.token.issued",
  tokenRevoked = "ias.token.revoked",
  sessionRevoked = "ias.session.revoked",
  clientSecretRotated = "ias.application.secret-rotated",
}

/// Driven port: publish domain events to a message broker (Event Mesh, Kafka …).
interface IIdentityEventPublisher {
  void publish(string topic, Json payload);
}

/// Publisher that drops all events (default when none is wired).
class NullEventPublisher : IIdentityEventPublisher {
  void publish(string topic, Json payload) {
  }
}

/// Publisher that keeps the events in memory (tests).
class RecordingEventPublisher : IIdentityEventPublisher {
  string[] topics;
  Json[] payloads;

  void publish(string topic, Json payload) {
    topics ~= topic;
    payloads ~= payload;
  }
}

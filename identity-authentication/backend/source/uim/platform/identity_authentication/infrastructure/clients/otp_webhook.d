/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// HTTP client adapter of the IOtpSender port: posts one-time codes to an SMS /
/// mail gateway webhook as {"channel", "destination", "message"}.
module uim.platform.identity_authentication.infrastructure.clients.otp_webhook;

import core.time : seconds;
import vibe.http.client : HTTPClientSettings, requestHTTP;
import vibe.http.common : HTTPMethod;
import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

class WebhookOtpSender : IOtpSender {
  protected string url;
  protected int timeoutSeconds;

  this(string url, int timeoutSeconds = 10) {
    this.url = url;
    this.timeoutSeconds = timeoutSeconds;
  }

  void send(MfaType channel, string destination, string message) {
    auto settings = new HTTPClientSettings;
    settings.connectTimeout = timeoutSeconds.seconds;
    settings.readTimeout = timeoutSeconds.seconds;
    auto payload = Json.emptyObject
      .set("channel", enumValue(channel))
      .set("destination", destination)
      .set("message", message);
    try {
      requestHTTP(url, (scope req) {
        req.method = HTTPMethod.POST;
        req.writeJsonBody(payload);
      }, (scope res) {
        if (res.statusCode >= 300)
          logError("identity-authentication: OTP webhook answered %d", res.statusCode);
      }, settings);
    } catch (Exception e) {
      logError("identity-authentication: OTP webhook failed: %s", e.msg);
    }
  }
}

/* global QUnit */
QUnit.config.autostart = false;
sap.ui.require([
  "uim/appevents/test/unit/formatter.qunit",
  "uim/appevents/test/unit/models.qunit",
  "uim/appevents/test/unit/session.qunit"
], function () {
  "use strict";
  QUnit.start();
});

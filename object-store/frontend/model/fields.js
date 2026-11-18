sap.ui.define([], function () {
  "use strict";

  var STORAGE_CLASSES = ["standard", "infrequentAccess", "nearline", "coldline", "archive"];

  /**
   * Fields of the generic create dialog per entity set.
   * type: text | number | bytes | textarea | switch | select | multi | list | keyvalues | date | hidden
   * (list = comma separated → string array, keyvalues = "k=v,k2=v2" → [{key, value}])
   */
  return {
    STORAGE_CLASSES: STORAGE_CLASSES,

    /** Entity set → display type (i18n key) and the table id holding its list binding. */
    SETS: {
      Buckets: { type: "typeBucket", table: "bucketTable" },
      StorageObjects: { type: "typeObject", table: "objectTable" },
      AccessPolicies: { type: "typePolicy", table: "policyTable" },
      LifecycleRules: { type: "typeLifecycleRule", table: "lifecycleTable" },
      CorsRules: { type: "typeCorsRule", table: "corsTable" },
      ServiceBindings: { type: "typeBinding", table: "bindingTable" }
    },

    CREATE_FIELDS: {
      Buckets: [
        { name: "name", label: "fldBucketName", required: true, hint: "hintBucketName" },
        { name: "description", label: "fldDescription" },
        { name: "provider", label: "fldProvider", type: "select", value: "aws", options: ["aws", "azure", "gcp", "alibaba"] },
        { name: "region", label: "fldRegion", type: "region", value: "" },
        { name: "storageClass", label: "fldStorageClass", type: "select", value: "standard", options: STORAGE_CLASSES.slice(0, 4) },
        { name: "versioningEnabled", label: "fldVersioning", type: "switch", value: true },
        { name: "encryptionType", label: "fldEncryption", type: "select", value: "sseS3", options: ["none", "sseS3", "sseKms", "sseC"] },
        { name: "encryptionKeyId", label: "fldEncryptionKeyId", hint: "hintKeyId" },
        { name: "publicAccessBlocked", label: "fldPublicAccessBlocked", type: "switch", value: true },
        { name: "quotaBytes", label: "fldQuota", type: "bytes", value: "0" },
        { name: "labels", label: "fldLabels", type: "keyvalues", hint: "hintKeyValues" }
      ],
      StorageObjects: [
        { name: "bucketId", type: "hidden" },
        { name: "name", label: "fldKey", required: true, hint: "hintKey" },
        { name: "contentType", label: "fldContentType", value: "text/plain" },
        { name: "content", label: "fldContent", type: "textarea" },
        { name: "metadata", label: "fldMetadata", type: "keyvalues", hint: "hintKeyValues" }
      ],
      AccessPolicies: [
        { name: "bucketId", type: "hidden" },
        { name: "name", label: "fldName", required: true },
        { name: "description", label: "fldDescription" },
        { name: "effect", label: "fldEffect", type: "select", value: "allow", options: ["allow", "deny"] },
        { name: "principals", label: "fldPrincipals", type: "list", required: true, value: "*", hint: "hintPrincipals" },
        { name: "actions", label: "fldActions", type: "multi", required: true, value: ["read", "list"],
          options: ["read", "write", "delete", "list", "all"] },
        { name: "resources", label: "fldResources", type: "list", value: "*", hint: "hintResources" },
        { name: "enabled", label: "fldEnabled", type: "switch", value: true }
      ],
      LifecycleRules: [
        { name: "bucketId", type: "hidden" },
        { name: "name", label: "fldName", required: true },
        { name: "prefix", label: "fldPrefix", hint: "hintPrefix" },
        { name: "status", label: "fldStatus", type: "select", value: "enabled", options: ["enabled", "disabled"] },
        { name: "transitionDays", label: "fldTransitionDays", type: "number", value: "30" },
        { name: "transitionStorageClass", label: "fldTransitionClass", type: "select", value: "coldline", options: STORAGE_CLASSES.slice(1) },
        { name: "expirationDays", label: "fldExpirationDays", type: "number", value: "0" },
        { name: "noncurrentVersionExpirationDays", label: "fldNoncurrentDays", type: "number", value: "0" }
      ],
      CorsRules: [
        { name: "bucketId", type: "hidden" },
        { name: "name", label: "fldName", required: true },
        { name: "allowedOrigins", label: "fldOrigins", type: "list", required: true, hint: "hintOrigins" },
        { name: "allowedMethods", label: "fldMethods", type: "multi", required: true, value: ["get"],
          options: ["get", "put", "post", "delete", "head"] },
        { name: "allowedHeaders", label: "fldAllowedHeaders", type: "list", value: "*" },
        { name: "exposedHeaders", label: "fldExposedHeaders", type: "list", value: "ETag" },
        { name: "maxAgeSeconds", label: "fldMaxAge", type: "number", value: "3600" }
      ],
      ServiceBindings: [
        { name: "bucketId", type: "hidden" },
        { name: "name", label: "fldName", required: true },
        { name: "description", label: "fldDescription" },
        { name: "permission", label: "fldPermission", type: "select", value: "readOnly", options: ["readOnly", "readWrite", "admin"] },
        { name: "expiresAt", label: "fldExpiresAt", type: "date" }
      ]
    },

    /** Convert the dialog value of a field into the OData payload value. */
    toPayload: function (oField) {
      var v = oField.value;
      switch (oField.type) {
        case "number":
          return parseInt(v, 10) || 0;
        case "bytes":
          return String(parseInt(v, 10) || 0); // Edm.Int64 (IEEE754Compatible)
        case "list":
          return String(v || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean);
        case "keyvalues":
          return String(v || "").split(",").map(function (s) { return s.trim(); }).filter(Boolean).map(function (s) {
            var i = s.indexOf("=");
            return i < 0 ? { key: s, value: "" } : { key: s.slice(0, i).trim(), value: s.slice(i + 1).trim() };
          });
        case "date":
          return v ? v + "T00:00:00Z" : null;
        default:
          return v;
      }
    }
  };
});

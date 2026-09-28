package mods.sm64cdpy

import androidx.work.Data

/**
 * Versioned installation identity shared by the MethodChannel, both Workers,
 * reconciliation and EventChannel payloads. Missing metadata is accepted only
 * for active operations created by older app versions.
 */
data class InstallIdentityMetadata(
    val section: String,
    val contentId: String,
    val artifactId: String,
    val contentKey: String,
    val artifactKey: String,
    val operationKey: String,
    val versionLabel: String?,
    val fileName: String?
) {
    companion object {
        const val SCHEMA_VERSION = 1
        const val KEY_SCHEMA_VERSION = "identitySchemaVersion"
        const val KEY_SECTION = "section"
        const val KEY_CONTENT_ID = "contentId"
        const val KEY_ARTIFACT_ID = "artifactId"
        const val KEY_CONTENT_KEY = "contentKey"
        const val KEY_ARTIFACT_KEY = "artifactKey"
        const val KEY_OPERATION_KEY = "operationKey"
        const val KEY_VERSION_LABEL = "versionLabel"
        const val KEY_FILE_NAME = "identityFileName"

        private val sections = setOf(
            "mods", "vip", "dynos", "touch_controls", "omm", "render96"
        )

        fun fromMap(values: Map<*, *>): InstallIdentityMetadata? = fromGetter {
            values[it]
        }

        fun fromData(data: Data): InstallIdentityMetadata? = fromGetter { key ->
            when (key) {
                KEY_SCHEMA_VERSION -> data.getInt(KEY_SCHEMA_VERSION, 0)
                else -> data.getString(key)
            }
        }

        private fun fromGetter(get: (String) -> Any?): InstallIdentityMetadata? {
            val schema = (get(KEY_SCHEMA_VERSION) as? Number)?.toInt()
                ?: (get(KEY_SCHEMA_VERSION) as? String)?.toIntOrNull()
                ?: return null
            require(schema == SCHEMA_VERSION) { "Unsupported install identity schema: $schema" }

            fun required(key: String): String =
                (get(key) as? String)?.trim()?.takeIf { it.isNotEmpty() }
                    ?: throw IllegalArgumentException("Missing install identity field: $key")

            val metadata = InstallIdentityMetadata(
                section = required(KEY_SECTION),
                contentId = required(KEY_CONTENT_ID),
                artifactId = required(KEY_ARTIFACT_ID),
                contentKey = required(KEY_CONTENT_KEY),
                artifactKey = required(KEY_ARTIFACT_KEY),
                operationKey = required(KEY_OPERATION_KEY),
                versionLabel = (get(KEY_VERSION_LABEL) as? String)?.trim()?.takeIf { it.isNotEmpty() },
                fileName = (get(KEY_FILE_NAME) as? String)?.trim()?.takeIf { it.isNotEmpty() }
            )
            require(metadata.section in sections) { "Unknown install section: ${metadata.section}" }
            require(metadata.contentKey.startsWith("v1|${metadata.section}|")) {
                "contentKey does not match section"
            }
            require(metadata.artifactKey.startsWith("${metadata.contentKey}|")) {
                "artifactKey does not match contentKey"
            }
            require(metadata.operationKey == metadata.artifactKey) {
                "operationKey must equal artifactKey"
            }
            return metadata
        }
    }

    fun toWorkDataPairs(): Array<Pair<String, Any?>> = arrayOf(
        KEY_SCHEMA_VERSION to SCHEMA_VERSION,
        KEY_SECTION to section,
        KEY_CONTENT_ID to contentId,
        KEY_ARTIFACT_ID to artifactId,
        KEY_CONTENT_KEY to contentKey,
        KEY_ARTIFACT_KEY to artifactKey,
        KEY_OPERATION_KEY to operationKey,
        KEY_VERSION_LABEL to versionLabel,
        KEY_FILE_NAME to fileName
    )

    fun addToEvent(event: MutableMap<String, Any?>) {
        event[KEY_SCHEMA_VERSION] = SCHEMA_VERSION
        event[KEY_SECTION] = section
        event[KEY_CONTENT_ID] = contentId
        event[KEY_ARTIFACT_ID] = artifactId
        event[KEY_CONTENT_KEY] = contentKey
        event[KEY_ARTIFACT_KEY] = artifactKey
        event[KEY_OPERATION_KEY] = operationKey
        versionLabel?.let { event[KEY_VERSION_LABEL] = it }
        fileName?.let { event[KEY_FILE_NAME] = it }
    }
}

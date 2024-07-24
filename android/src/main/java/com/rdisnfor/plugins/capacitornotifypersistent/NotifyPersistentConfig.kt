package com.rdisnfor.plugins.capacitornotifypersistent

data class NotifyPersistentConfig(
    val presentationOptions: List<String> = listOf("badge", "sound", "alert")
)
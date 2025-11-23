package net.thunderbird.android.provider

import android.os.Build
import net.thunderbird.android.R
import net.thunderbird.core.preference.GeneralSettingsManager
import net.thunderbird.core.preference.display.visualSettings.DisplayVisualSettingsPreferenceManager
import net.thunderbird.core.ui.theme.api.ThemeProvider

internal class TbThemeProvider(
    private val visualSettingsManager: DisplayVisualSettingsPreferenceManager,
) : ThemeProvider {
    private val useDynamicColors: Boolean
        get() = visualSettingsManager.getConfig().useMaterialYou &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.S

    override val appThemeResourceId: Int
        get() = if (useDynamicColors) {
            R.style.Theme2_Thunderbird_DayNight_DynamicColors
        } else {
            R.style.Theme_Thunderbird_DayNight
        }

    override val appLightThemeResourceId: Int
        get() = if (useDynamicColors) {
            R.style.Theme2_Thunderbird_Light_DynamicColors
        } else {
            R.style.Theme_Thunderbird_Light
        }

    override val appDarkThemeResourceId: Int
        get() = if (useDynamicColors) {
            R.style.Theme2_Thunderbird_Dark_DynamicColors
        } else {
            R.style.Theme_Thunderbird_Dark
        }

    override val dialogThemeResourceId = R.style.Theme_Thunderbird_DayNight_Dialog
    override val translucentDialogThemeResourceId = R.style.Theme_Thunderbird_DayNight_Dialog_Translucent
}

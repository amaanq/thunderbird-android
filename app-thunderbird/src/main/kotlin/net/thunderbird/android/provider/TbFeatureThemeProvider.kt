package net.thunderbird.android.provider

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import app.k9mail.core.ui.compose.theme2.thunderbird.ThunderbirdTheme2
import net.thunderbird.core.preference.GeneralSettingsManager
import net.thunderbird.core.ui.theme.api.FeatureThemeProvider
import org.koin.compose.koinInject

internal class TbFeatureThemeProvider : FeatureThemeProvider {
    @Composable
    override fun WithTheme(content: @Composable () -> Unit) {
        val settingsManager: GeneralSettingsManager = koinInject()
        val settings by settingsManager.getConfigFlow().collectAsState(initial = settingsManager.getConfig())
        val useMaterialYou = settings.display.visualSettings.useMaterialYou

        ThunderbirdTheme2(dynamicColor = useMaterialYou) {
            content()
        }
    }

    @Composable
    override fun WithTheme(darkTheme: Boolean, content: @Composable () -> Unit) {
        val settingsManager: GeneralSettingsManager = koinInject()
        val settings by settingsManager.getConfigFlow().collectAsState(initial = settingsManager.getConfig())
        val useMaterialYou = settings.display.visualSettings.useMaterialYou

        ThunderbirdTheme2(darkTheme = darkTheme, dynamicColor = useMaterialYou) {
            content()
        }
    }
}

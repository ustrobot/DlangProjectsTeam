module ui.settings_ui;

/**
 * Interface for settings dialog implementations.
 * Allows different UI frameworks to be used interchangeably.
 */
interface ISettingsDialog
{
    /**
     * Show the settings dialog
     */
    void show();
}

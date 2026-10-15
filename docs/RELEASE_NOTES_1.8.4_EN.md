## SM64CDPY v1.8.4 — A faster, more responsive Library

Version 1.8.4 streamlines Library loading and makes game mod controls respond immediately while Android safely confirms configuration changes.

### A smoother Library

- Opening Game mods or DynOS no longer starts receipt checks and update-catalog work in the background.
- Returning to either game-content section reuses its recent snapshot. The list remains visible during refresh, and game folder changes and completed installs invalidate the snapshot; resuming while the section is open or refreshing manually requests current data.
- The section counts appear as their data becomes available, without delaying the active view for information it does not need.

### Faster activation feedback

- After confirmation, the selected Lua mod or DynOS pack updates on screen immediately while Android saves the game configuration.
- A pending indicator remains until Android verifies the exact written configuration. If saving fails, the control returns to its last confirmed state.
- The manager validates the selected game item and relevant active Lua metadata instead of rebuilding the complete list after every change. Lua size checks, configuration backup, conflict protection and installation safeguards remain in place.
- The game applies changes on its next start. SAF provider speed and large mod folders can still affect the time needed to confirm a real file write.

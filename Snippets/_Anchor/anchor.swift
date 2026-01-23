/// This target functions as an anchor to remind SwiftPM to link `libm` before trying to compile
/// snippets. Without it, there would be no attachment point for the linker settings, unless we
/// were to dirty the actual library targets with snippet-specific settings

//! Software-update notice. Network and self-update behavior stay disabled until April Software
//! provides an approved signed update service.

use crate::WordApp;

#[derive(Default)]
pub(crate) struct Runtime {
    manual_window_open: bool,
}

/// Answer the retained update command locally without contacting an update service.
pub(crate) fn check(app: &mut WordApp) {
    app.updates_rt.manual_window_open = true;
}

/// Kept in the frame lifecycle so a future approved implementation has one integration point.
pub(crate) fn tick(_app: &mut WordApp, _ctx: &egui::Context) {}

pub(crate) fn show(app: &mut WordApp, ctx: &egui::Context) {
    if !app.updates_rt.manual_window_open {
        return;
    }
    let mut open = true;
    let mut close = false;
    egui::Window::new(tl!("Software Updates"))
        .open(&mut open)
        .resizable(false)
        .collapsible(false)
        .anchor(egui::Align2::CENTER_CENTER, egui::vec2(0.0, 0.0))
        .show(ctx, |ui| {
            ui.label(tl!(
                "Automatic updates are disabled until an April Software update service is available. April Writer does not contact an update service."
            ));
            ui.add_space(8.0);
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                if ui.button(tl!("Close")).clicked() {
                    close = true;
                }
            });
        });
    if !open || close {
        app.updates_rt.manual_window_open = false;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Services;

    #[test]
    fn manual_check_only_opens_the_disabled_notice() {
        let mut app = WordApp::new(wordcraft_engine::Session::new(wordcraft_doc::Document::new()), Services::default());
        assert!(!app.updates_rt.manual_window_open);
        check(&mut app);
        assert!(app.updates_rt.manual_window_open);
    }
}

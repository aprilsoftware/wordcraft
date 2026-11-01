//! Windows only: embed the app icon and version info (VERSIONINFO) into `aprilwriter.exe`, so it
//! shows in Explorer, the taskbar, the Start menu and Alt-Tab.
//!
//! On every other target this does nothing. A missing resource compiler is a warning, so a
//! cross-compile from macOS or Linux still links, unless `APRILWRITER_REQUIRE_WINRES=1` turns it
//! into an error (for release builds).

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=../../assets/app-icon/aprilwriter.ico");
    println!("cargo:rerun-if-env-changed=APRILWRITER_REQUIRE_WINRES");
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() != Ok("windows") {
        return;
    }
    let mut res = winresource::WindowsResource::new();
    res.set_icon("../../assets/app-icon/aprilwriter.ico")
        .set("ProductName", "April Writer")
        .set("FileDescription", "April Writer word processor")
        .set("CompanyName", "April Software S.A.")
        .set("LegalCopyright", "Copyright (c) 2026 April Software S.A. Original WordCraft copyrights retained.")
        .set("OriginalFilename", "aprilwriter.exe")
        .set("InternalName", "aprilwriter");
    if let Err(e) = res.compile() {
        if std::env::var_os("APRILWRITER_REQUIRE_WINRES").is_some() {
            eprintln!("embedding Windows resources failed: {e}");
            std::process::exit(1);
        }
        println!("cargo:warning=aprilwriter.exe built without icon/version resources: {e}");
    }
}

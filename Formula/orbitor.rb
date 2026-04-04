class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.64"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "fd3e90ad26329bc74d9424be1b682e041138630c82739653e70c0e87d9fe3f13"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "98bc75141ff78bbfdb142d420912ab42429fffd8c88ee5257f3c25a8bc5dd7e3"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.64/orbitor-desktop-macos.zip"
      sha256 "fc655d76b4b912c6c2fc0fc2e5e1a088c2cf4c269ab2405e9fbda91569bee68d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "e7eab98f66bf7cd1adb79c81246824b23f7a725c047a9d6477cc4119e73861ea"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "94edbbaa1f0855c3f6c1ed20233e1a832a78525f214771e543042c4fbef30c14"
    end
  end

  def install
    bin.install Dir["orbitor-*"].first => "orbitor"

    if OS.mac?
      resource("desktop").stage do
        prefix.install "Orbitor.app"
      end
    end
  end

  def post_install
    (Pathname.new(ENV["HOME"]) / ".orbitor").mkpath
    # Kill any existing orbitor server processes so the port is freed before
    # the service restarts. Without this, the new server can't bind because
    # the old process (possibly started outside brew services) still holds it.
    quiet_system "pkill", "-f", "orbitor server"
    quiet_system "pkill", "-f", "orbitor.*server"
    sleep 2
    # Restart the background service after upgrade so the new binary is used.
    # quiet_system avoids errors when the service isn't running yet.
    quiet_system "brew", "services", "restart", "orbitor"

    if OS.mac?
      user_apps = Pathname.new(ENV["HOME"]) / "Applications"
      user_apps.mkpath
      app_dest = user_apps / "Orbitor.app"
      app_src = opt_prefix / "Orbitor.app"
      if app_dest.exist?
        # macOS 13+ sets com.apple.provenance on app bundles; remove it so
        # the bundle can be deleted. On macOS 15+ (Darwin 24+), ~/Applications
        # is TCC-protected and brew's subprocess may lack permission — fall back
        # to a manual-install instruction in that case.
        quiet_system "xattr", "-d", "com.apple.provenance", app_dest.to_s
        quiet_system "rm", "-rf", app_dest.to_s
      end
      unless quiet_system("ditto", app_src.to_s, app_dest.to_s)
        opoo "Could not update #{app_dest.basename} automatically (macOS permission restriction)."
        opoo "Run this from your terminal to update it:"
        opoo "  ditto #{app_src} #{app_dest}"
      end
    end
  end

  service do
    run [opt_bin/"orbitor", "server"]
    keep_alive true
    log_path var/"log/orbitor.log"
    error_log_path var/"log/orbitor.log"
    working_dir ENV["HOME"]
  end

  def caveats
    <<~EOS
      Run the setup wizard to configure orbitor:
        orbitor setup

      To start the server as a background service:
        brew services start orbitor

      Open the TUI:
        orbitor

      The macOS desktop app has been installed to ~/Applications/Orbitor.app.
    EOS
  end

  test do
    system "#{bin}/orbitor", "--version" rescue nil
    assert_predicate bin/"orbitor", :exist?
  end
end

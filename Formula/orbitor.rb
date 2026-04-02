class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.62"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "3a53d786cf2d2d92d6e496ee6ccd3e64c19999e54218a0f8fa43851caa6418e3"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "00c4bbe57872ebaed993c9b22858debb612e132d4660bddb89489560142718d5"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.62/orbitor-desktop-macos.zip"
      sha256 "3a3d64e634b4a0cf843b2339fdbc4da730106500b99b523270e8f5ce5790f522"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "fadd0a4e9f7e9cc927a39dbbb5217acc5330d1bd239cc22b9541cf931e24d5d5"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "bf068829e0cfd3cc1d47497f8b19b32ec4434a8f5110d3cd1369e9e337109d86"
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

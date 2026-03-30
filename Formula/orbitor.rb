class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.60"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "964d639ffab0fdea31267cb08424884f5585f3a2d1e6112319ac7f753c2462ff"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "fc5ecdc6eea2acf03a723846742bc895739188b6100f297813f54721f074fe23"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.60/orbitor-desktop-macos.zip"
      sha256 "356a8c21b94838ba31db4e8c91577ec7dd28e99845b93d9cf7a94307a077bac8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "0a32aa1dccce1810e1ad68f2d7354a675cc3cebc15f80f2fe41f228a0ce956b8"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "75b39a171e5b039f7dfc04a3c6c562e4dd053cca3f1ce1b46852b8c2ffcd5b37"
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

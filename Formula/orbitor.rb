class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.61"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "44b6b1abfb71e2026b4d20a6ef29c05cf977894abb633df6fc1be2f762c59ae1"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "0acea1462dfbd45a54eaf12b798792f4341ba02fdff2eada97cbe28ca68f5525"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.61/orbitor-desktop-macos.zip"
      sha256 "8a38c397cfe53de28a232d2e98b242d0bdc5485062aa2b488c1ba051b8965cc4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "4edef829ef953c3de88a46e3f4da3c1cc1b2f246bc56b203bd06a3e4260ff678"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "67b3117b16be51ae6ad2ff726f30a9b127df8481db16472ffe042c5f177adf5a"
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

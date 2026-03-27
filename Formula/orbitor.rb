class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.49"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "9eaff4002caf1f65234889646511df1ce7ef4f46b29ea1e96c1e0693efc057d3"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "56624e0e0e2288a54d21477af7c6d8711d8749912b0ded830ce299ded57ee1c9"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.49/orbitor-desktop-macos.zip"
      sha256 "ad40201fbddf8dd5a307df0d61f4cf08cd9460b8322721c0d119166627df7da3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "256c67a98c714bb7c966d1ac4be9a3ab4241e9b235a499b94893e348363176bd"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "f6b1420fcb1f1097fdc0e0b0de93d88a2db4859fc40717d9cbd50afd488bf49f"
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
      # Symlink the desktop app into ~/Applications
      user_apps = Pathname.new(ENV["HOME"]) / "Applications"
      user_apps.mkpath
      app_link = user_apps / "Orbitor.app"
      app_link.unlink if app_link.exist? || app_link.symlink?
      app_link.make_symlink(prefix / "Orbitor.app")
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

      The macOS desktop app has been symlinked to ~/Applications/Orbitor.app.
    EOS
  end

  test do
    system "#{bin}/orbitor", "--version" rescue nil
    assert_predicate bin/"orbitor", :exist?
  end
end

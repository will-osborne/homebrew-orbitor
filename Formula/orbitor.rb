class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.58"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "33b9660372b9305e3cead273522c091531a57404297a8dd7e656a8f09e529450"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "a61f38b7d3b20e718d3b79182185d80ba1853cf4e0517e2aeda2571bdceea27c"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.58/orbitor-desktop-macos.zip"
      sha256 "e164e2fa289989e0b96fd5f4a44443268d9555efb23b15fb63c430fcc62227e7"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "f99586770be9fc2a49c590780415b9177ac147c8211c066ece00f98dd7929e12"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "ce0b0c99b2086685f98561df5673db47fc74e4c2e673861d547323c1051d6365"
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
      # Install the desktop app into ~/Applications using ditto, which
      # overwrites in-place without requiring delete (avoids EPERM on
      # protected app bundles that have been run by the user).
      user_apps = Pathname.new(ENV["HOME"]) / "Applications"
      user_apps.mkpath
      app_dest = user_apps / "Orbitor.app"
      system "ditto", (opt_prefix / "Orbitor.app").to_s, app_dest.to_s
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

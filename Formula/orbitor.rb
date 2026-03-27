class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.52"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "f43b6eb00e5eed063044320a44fb14d30ce1b8b5fd700d3c37bffbba7205bdfa"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "dcc501a3252cb640d170b4e5292470048d45a2981a5e63d9b4c42c5d407d7ec2"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.52/orbitor-desktop-macos.zip"
      sha256 "5a98a3b11802cfbc8451c5833b1f4faaf0dc9d9488e41a73c41d252377079b63"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "6150fb7c38ce48ed0bd3ef39f7df44da7da83729120c691815671fdb1911e4e0"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "72f04ece9603585034dfccebc128aecbfc88a451ec61c4b08660c58f7a5963ee"
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
      # Install the desktop app into ~/Applications
      user_apps = Pathname.new(ENV["HOME"]) / "Applications"
      user_apps.mkpath
      app_dest = user_apps / "Orbitor.app"
      system "rm", "-rf", app_dest.to_s
      system "cp", "-R", (opt_prefix / "Orbitor.app").to_s, app_dest.to_s
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

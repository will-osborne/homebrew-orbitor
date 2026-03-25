class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.37"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "1c1ea2e9cf123fb6f324081f76acbc2e5a0cbbd1c9b878156469046b5d572ee9"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "f7737c0734ab075bd28b7f46519dee45ac6ce1fd6e6989b8216c1491d4bce619"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "95a7527b78a98e08a8dfc408200e77a700127298a8dd370d2a3ec33f9d9126d2"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "d7bc9e6a2d2bf888e328f0f8da96f22236899509b99b8936b4aa815b3ee15d5a"
    end
  end

  def install
    bin.install Dir["orbitor-*"].first => "orbitor"
  end

  def post_install
    (Pathname.new(ENV["HOME"]) / ".orbitor").mkpath
    # Restart the background service after upgrade so the new binary is used.
    # quiet_system avoids errors when the service isn't running yet.
    quiet_system "brew", "services", "restart", "orbitor"
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
        orbitor service install
      or via Homebrew services:
        brew services start orbitor

      Open the TUI:
        orbitor
    EOS
  end

  test do
    system "#{bin}/orbitor", "--version" rescue nil
    assert_predicate bin/"orbitor", :exist?
  end
end

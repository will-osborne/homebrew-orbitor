class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.8"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "ba8ef69d72674adc30b8a7550c341217c2c187efdeedce0eb0304a1b77428681"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "0a9e32e01c8cb6dc9346fcca0befb12452487350fd3cd81e178d858321dde192"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "a253b458910cb7aebc82b8745971ead6c1fc43c991062630635d33cd8788cd7c"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "512440272d9741e38c78b3765de811487bc298eb33fb2799b967b636c9f6ebff"
    end
  end

  def install
    bin.install Dir["orbitor-*"].first => "orbitor"
  end

  def post_install
    (Pathname.new(ENV["HOME"]) / ".orbitor").mkpath
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

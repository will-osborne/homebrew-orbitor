class Orbitor < Formula
  desc "AI coding assistant bridge — TUI + mobile interface for Claude Code and GitHub Copilot"
  homepage "https://github.com/will-osborne/orbitor"
  version "0.1.59"

  on_macos do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-arm64"
      sha256 "9268c35292d4e36235835570139a55aef7e6e9ce6398e3dda3867778cc697d07"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-darwin-amd64"
      sha256 "5fce11dc7ad102cdc49937e694d57b7218fcc5428cfe24a4718e43dfa1dd220c"
    end

    resource "desktop" do
      url "https://github.com/will-osborne/orbitor/releases/download/v0.1.59/orbitor-desktop-macos.zip"
      sha256 "af1ca2e20393a76e855b94f064fdc95be50e4166db8a117236e521437d8b0364"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-arm64"
      sha256 "ff1b1f7f5d8f082e476a3f31b2c3c81d86b42d438d113204d03c644d9c274b7d"
    end
    on_intel do
      url "https://github.com/will-osborne/orbitor/releases/download/v#{version}/orbitor-linux-amd64"
      sha256 "43f04b5fd466ab9d3c338e75e85972a7df71bfce02656d39035466c8c87a1e29"
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
      # Install the desktop app into ~/Applications.
      # macOS protects app bundles that have been run by the user, so we
      # must restore write permissions before removing the old bundle.
      user_apps = Pathname.new(ENV["HOME"]) / "Applications"
      user_apps.mkpath
      app_dest = user_apps / "Orbitor.app"
      if app_dest.exist?
        system "chmod", "-R", "u+w", app_dest.to_s
        system "rm", "-rf", app_dest.to_s
      end
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

class Tempbar < Formula
  desc "Menu bar app showing the inside and outside temperature"
  homepage "https://github.com/ankitsxchdeva/TempBar"
  url "https://github.com/ankitsxchdeva/TempBar/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "90b8907c332787cdd6e225ba215895c986b3b333e8534c6db210187b96c19147"
  license "MIT"
  head "https://github.com/ankitsxchdeva/TempBar.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sequoia

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"

    app = prefix/"TempBar.app"
    (app/"Contents/MacOS").install ".build/release/TempBar"
    (app/"Contents").install "Resources/Info.plist"
    system "codesign", "--force", "--sign", "-", app

    (bin/"tempbar").write <<~SH
      #!/bin/sh
      exec open "#{opt_prefix}/TempBar.app" "$@"
    SH
  end

  def caveats
    <<~EOS
      TempBar is a menu bar app. Start it with:
        tempbar

      To keep it in Spotlight and Launchpad, link it into your Applications folder:
        ln -sfn #{opt_prefix}/TempBar.app ~/Applications/TempBar.app

      The app is signed ad hoc on your machine, so macOS asks again for
      Keychain access to the Home Assistant token after each upgrade.
    EOS
  end

  test do
    app = prefix/"TempBar.app"
    assert_path_exists app/"Contents/Info.plist"
    assert_predicate app/"Contents/MacOS/TempBar", :executable?
    system "codesign", "--verify", "--strict", app
  end
end

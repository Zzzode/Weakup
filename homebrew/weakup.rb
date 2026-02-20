# Homebrew Cask formula for Weakup
# To install: brew install --cask weakup
#
# For development/testing:
#   brew install --cask ./homebrew/weakup.rb
#
# To submit to homebrew-cask:
#   1. Fork https://github.com/Homebrew/homebrew-cask
#   2. Add this file to Casks/w/weakup.rb
#   3. Submit a pull request

cask "weakup" do
  version "1.0.0"
  sha256 "PLACEHOLDER_SHA256"  # Update with actual SHA256 of the ZIP file

  url "https://github.com/Zzzode/weakup/releases/download/v#{version}/Weakup-#{version}.zip"
  name "Weakup"
  desc "Lightweight macOS utility to prevent your Mac from sleeping"
  homepage "https://github.com/Zzzode/weakup"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "Weakup.app"

  zap trash: [
    "~/Library/Preferences/com.weakup.app.plist",
    "~/Library/Caches/com.weakup.app",
  ]
end

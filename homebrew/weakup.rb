# typed: strict
# frozen_string_literal: true

# Homebrew Cask formula for Weakup
# To install locally: brew install --cask ./homebrew/weakup.rb
#
# For development/testing:
#   brew install --cask ./homebrew/weakup.rb
#
# To submit to homebrew-cask:
#   1. Fork https://github.com/Homebrew/homebrew-cask
#   2. Add this file to Casks/w/weakup.rb
#   3. Submit a pull request

cask "weakup" do
  version "1.0.2"
  sha256 "0c951b7405fdc560c15950252a4ea44e321c9b60d1513644da0195c70fd5df4d"

  url "https://github.com/Zzzode/weakup/releases/download/v#{version}/Weakup-#{version}.zip"
  name "Weakup"
  desc "Lightweight utility that prevents idle and display sleep"
  homepage "https://github.com/Zzzode/weakup"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "Weakup.app"

  zap trash: [
    "~/Library/Caches/com.weakup.app",
    "~/Library/Preferences/com.weakup.app.plist",
  ]
end

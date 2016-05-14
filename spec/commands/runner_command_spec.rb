module Command
  describe Danger::Runner do
    before do
      # Danger local stuff
      allow(ENV).to receive(:[]).with("DANGER_USE_LOCAL_GIT").and_return(nil)
      allow(ENV).to receive(:[]).with("DANGER_GITHUB_HOST").and_return("")
      allow(ENV).to receive(:[]).with("DANGER_GITHUB_API_TOKEN").and_return("11")
      allow(ENV).to receive(:[]).with("DANGER_GITHUB_API_HOST").and_return(nil)

      # We'll take the first CI Source
      allow(ENV).to receive(:[]).with("BUILDKITE").and_return("SURE")
      allow(ENV).to receive(:[]).with("BUILDKITE_REPO").and_return("git@github.com:artsy/eigen.git")
      allow(ENV).to receive(:[]).with("BUILDKITE_PULL_REQUEST").and_return("800")

      # ENV vars used under the hood
      allow(ENV).to receive(:[]).with("http_proxy").and_return(nil)
      allow(ENV).to receive(:[]).with("TMPDIR").and_return(nil)
      allow(ENV).to receive(:[]).with("TMP").and_return(nil)
      allow(ENV).to receive(:[]).with("TEMP").and_return(nil)
      allow(ENV).to receive(:[]).with("CLAIDE_DISABLE_AUTO_WRAP").and_return(nil)

      # Mock out the octokit object with our fixtured data
      octokit_mock = Object

      pr_response = JSON.parse(fixture("pr_response"), symbolize_names: true)
      allow(octokit_mock).to receive(:pull_request).with("artsy/eigen", "800").and_return(pr_response)
      issue_response = JSON.parse(fixture("issue_response"), symbolize_names: true)
      allow(octokit_mock).to receive(:get).with("https://api.github.com/repos/artsy/eigen/issues/800").and_return(issue_response)
      issue_comments_response = JSON.parse(fixture("issue_comments"), symbolize_names: true)
      allow(octokit_mock).to receive(:issue_comments).with("artsy/eigen", "800").and_return(issue_comments_response)

      Octokit::Client.stub(:new).and_return octokit_mock
    end

    it 'runtime errors when no Dangerfile found' do
      Dir.mktmpdir do |dir|
        Dir.chdir dir do
          expect { Danger::Runner.run([]) }.to raise_error SystemExit
        end
      end
    end

    it 'runtime errors when no Dangerfile found' do
      Dir.mktmpdir do |dir|
        Dir.chdir dir do
          `git init`
          # `git remote add origin git@github.com:artsy/eigen.git`
          `touch Dangerfile`
          expect { Danger::Runner.run([]) }.to_not raise_error SystemExit
        end
      end
    end
  end
end

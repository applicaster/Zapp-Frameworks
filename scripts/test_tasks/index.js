const fs = require("fs");
const { exec } = require("shelljs");
const { abort } = require("./helper.js");

async function prepareBuidEnvironment({ pluginPath, iosModuleName }) {
  if (iosModuleName && pluginPath) {
    try {
      const iosPluginPath = `${pluginPath}/apple`;
      const isPodfileExist = fs.existsSync(`${iosPluginPath}/Podfile`);
      const isPackageJsonExist = fs.existsSync(`${pluginPath}/package.json`);

      if (isPodfileExist) {
        if (isPackageJsonExist) {
          await exec(`cd ${pluginPath} && npm install`);
        }

        await exec(`cd ${iosPluginPath} && bundle exec pod install`);

        return true;
      } else {

        return false;
      }
    } catch (e) {
      abort(e.message);

      return false;
    }
  } else {
    return false;
  }
}

async function iosBuildUnitTests({ iosModuleName, pluginPath }) {
  console.log("iosBuildUnitTests:", { iosModuleName, pluginPath });

  if (iosModuleName && pluginPath) {
    try {
      const readyToBuild = await prepareBuidEnvironment({
        iosModuleName,
        pluginPath,
      });

      console.log({ readyToBuild });
      const artifactsFolder = `CircleArtifacts/test-results/${iosModuleName}`;
      const appleFolderPath = `${pluginPath}/apple`;

      if (readyToBuild) {
        await exec(`mkdir -p ${artifactsFolder}`);

        await exec(`cd ${pluginPath}/apple && set -euxo pipefail && xcodebuild \
        -workspace ./FrameworksApp.xcworkspace \
        -scheme ${iosModuleName} \
        -destination 'platform=iOS Simulator,OS=14.4,name=iPhone 12' \
        clean build test | tee xcodebuild.log | xcpretty --report html --output report.html`, function (err, stdout) {
            if (err) throw err;
        });

        return await exec(
          `mv ${appleFolderPath}/xcodebuild.log ${artifactsFolder}/ios-xcodebuild.log \
          && mv ${appleFolderPath}/report.html ${artifactsFolder}/ios-report.html`
        );
      }
    } catch (e) {
      abort(e.message);
    }
  }
}

async function buildDocumentation({ iosModuleName, pluginPath }) {
  if (
    iosModuleName &&
    pluginPath &&
    fs.existsSync(`${pluginPath}/apple/.jazzy.json`)
  ) {
    try {
      const readyToBuild = await prepareBuidEnvironment();

      if (readyToBuild) {
        return await exec(
          `cd ${pluginPath}/apple && bundle exec jazzy --config .jazzy.json`
        );
      }
    } catch (e) {
      abort(e.message);
    }
  }
}

module.exports = { iosBuildUnitTests, buildDocumentation };

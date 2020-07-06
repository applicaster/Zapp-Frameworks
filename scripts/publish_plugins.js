#!/usr/bin/env node

const { resolve } = require("path");

const rootPath = resolve(__dirname, "..");

const git = require("simple-git/promise")(rootPath);
const shelljs = require("shelljs");
const R = require("ramda");
const semver = require("semver");

const { retrieveDiffedPlugins } = require("./get_changed_plugins");

async function exec(command, options) {
  return new Promise((resolve, reject) => {
    shelljs.exec(
      command,
      {
        cwd: rootPath,
        silent: true,
        ...options,
      },
      (code, stdIn, stdErr) => {
        if (code === 0) {
          resolve(stdIn);
        } else {
          reject(stdErr);
        }
      }
    );
  });
}
function isCanary() {
  return process.argv[2] === "--canary";
}

async function publishPlugin({ pluginFolder, newVersion }) {
  const pluginPath = `plugins/${pluginFolder}`;
  console.log({ pluginPath });
  const latestCommitSha = await exec(
    `git log -n 1 --pretty=format:%h "${pluginPath}"`
  );
  console.log({ newCanary: `${newVersion}-alpha.${latestCommitSha}` });
  const command = isCanary()
    ? `yarn publish:plugin:canary ${pluginPath} -v ${newVersion}-alpha.${latestCommitSha}`
    : `yarn publish:plugin ${pluginPath} -v ${newVersion}`;
  try {
    const output = await exec(command);

    return output;
  } catch (e) {
    throw e;
  }
}
async function run() {
  console.log("#--------------------#");
  console.log("  Publishing plugins  ");
  console.log("#--------------------#\n");

  console.log({ argv: process.argv });
  try {
    if (!isCanary) {
      await exec("git checkout -- .");
      await exec("git clean -fd");
    }

    const diffedPlugins = await retrieveDiffedPlugins();
    const result = await Promise.all(R.map(publishPlugin)(diffedPlugins));
    console.log(`Plugins are published`, result);

    if (!isCanary()) {
      await startGitTask(diffedPlugins);
    }

    return result;
  } catch (e) {
    console.log(
      "An error occured while publishing plugins, please check the error below"
    );
    console.error(e);
    process.exit(1);
  }
}

async function startGitTask(diffedPlugins) {
  console.log(`Pushing commits`);
  await exec(
    "git push origin ${CIRCLE_BRANCH} --quiet > /dev/null 2>&1" // eslint-disable-line
  );

  await createGitTags(diffedPlugins);
}

async function createGitTags(diffedPlugins) {
  console.log({ diffedPlugins });
  for (const plugin of diffedPlugins) {
    const tag = await getNewTagName(plugin);
    await createTag(tag);
  }
}

async function getNewTagName({ pluginFolder, newVersion }) {
  const packageJson = await getPackageJson({ pluginFolder });
  const pluginName = packageJson.name;
  console.log(`${pluginName}/${newVersion}`);

  return `${pluginName}/${newVersion}`;
}

async function createTag(newTagName) {
  console.log("createTag", newTagName);
  await exec(`git tag ${newTagName}`);
  await exec(`git push origin ${newTagName}`);
}

async function getPackageJson({ pluginFolder }) {
  const resolvedPluginPath = resolve(process.cwd(), `plugins/${pluginFolder}`);
  const pJsonPath = resolve(resolvedPluginPath, "package.json");

  try {
    return (pluginPackageJson = require(pJsonPath));
  } catch (e) {
    throw new Error(
      "Could not find the plugin package.json file. Make sure the path is correct"
    );
  }
}
run();

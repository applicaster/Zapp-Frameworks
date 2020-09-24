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
  const canaryRequested = isCanary();
  const packageJson = await getPackageJson({ pluginFolder });
  const pluginName = packageJson.name;

  const pluginPath = `plugins/${pluginFolder}`;
  console.log({ pluginPath });

  const newCanaryVersion = await canaryVersion({ pluginName, newVersion });
  if (canaryRequested) {
    console.log({ newCanaryVersion });
  }

  const command = canaryRequested
    ? `yarn publish:plugin:canary ${pluginPath} -v ${newCanaryVersion}`
    : `yarn publish:plugin ${pluginPath} -v ${newVersion}`;
  try {
    const output = await exec(command);
    console.log({ output });
    return output;
  } catch (e) {
    throw e;
  }
}
async function canaryVersion({ pluginName, newVersion }) {
  const data = await exec(`yarn info ${pluginName} --json`);
  if (data) {
    const parsed = data && JSON.parse(data);
    const distTags = parsed.data["dist-tags"];

    const next = distTags && distTags.next;
    if (next) {
      const corsedNextVersion = semver.coerce(next);
      const compareVersions = semver.compare(newVersion, corsedNextVersion);

      if (compareVersions === 0) {
        const incrementedAlpha = semver.inc(next, "prerelease", "alpha");

        if (incrementedAlpha) {
          return incrementedAlpha;
        }
      }
    }
  }
  return `${newVersion}-alpha.0`;
}

async function publishAllPlugins(diffedPlugins) {
  for (const plugin of diffedPlugins) {
    const result = await publishPlugin(plugin);
    console.log({ result });
  }
}

async function run() {
  console.log("#--------------------#");
  console.log("  Publishing plugins  ");
  console.log("#--------------------#\n");
  try {
    const diffedPlugins = await retrieveDiffedPlugins();
    await publishAllPlugins(diffedPlugins);
    console.log(`Plugins are published`);
    if (!isCanary()) {
      await startGitTask(diffedPlugins);
    }
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

  return `${pluginName}@${newVersion}`;
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

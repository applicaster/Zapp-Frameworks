#!/usr/bin/env node
/* eslint-disable no-console */

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

async function publishPlugin({ pluginFolder, newVersion }) {
  try {
    const output = await exec(
      `yarn publish:plugin plugins/${pluginFolder} -v ${newVersion}`
    );

    return output;
  } catch (e) {
    throw e;
  }
}
async function run() {
  console.log("#--------------------#");
  console.log("  Publishing plugins  ");
  console.log("#--------------------#\n");

  try {
    await exec("git checkout -- .");
    await exec("git clean -fd");

    const diffedPlugins = await retrieveDiffedPlugins();
    const result = await Promise.all(R.map(publishPlugin)(diffedPlugins));

    console.log(`Plugins are published, pushing commits`);
    await exec(
      "git push origin ${CIRCLE_BRANCH} --quiet > /dev/null 2>&1" // eslint-disable-line
    );

    await createGitTags(diffedPlugins);
    return result;
  } catch (e) {
    console.log(
      "An error occured while publishing plugins, please check the error below"
    );
    console.error(e);
    process.exit(1);
  }
}

async function createGitTags(diffedPlugins) {
  const tagsToCreate = R.map(getNewTagName)(diffedPlugins);
  for (const tag of tagsToCreate) {
    await createTag(tag);
  }
}

function getNewTagName({ pluginFolder, newVersion }) {
  return `@${pluginFolder}/${newVersion}`;
}

async function createTag(newTagName) {
  await exec(`git tag ${newTagName}`);
  await exec(`git push origin ${newTagName}`);
}
run();

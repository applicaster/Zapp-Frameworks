#!/usr/bin/env node
/* eslint-disable no-console */

const { readdir } = require("fs");
const { resolve } = require("path");
const { promisify } = require("util");

const rootPath = resolve(__dirname, "..");

const git = require("simple-git/promise")(rootPath);
const shelljs = require("shelljs");
const R = require("ramda");
const semver = require("semver");

const readdirAsync = promisify(readdir);

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

function getCommitMessage(pluginPath) {
  const { version, name } = require(resolve(
    __dirname,
    "..",
    pluginPath,
    "package.json"
  ));

  return `chore: publish .*${name}@${version}.*`;
}

async function getLastCommit() {
  return exec("git log -1 --pretty=tformat:%s | cat");
}

async function getLatestVersionSha(pluginPath) {
  const commitMessage = getCommitMessage(pluginPath);

  const result = await exec(
    `git log --grep="${commitMessage}" --pretty=tformat:%h | cat`
  );

  return R.replace("\n", "", result);
}

async function getLatestTag() {
  const latestTag = await git.raw(["describe", "--abbrev=0"]);
  console.log({ latestTag });
  return R.replace("\n", "", latestTag);
}

async function getDiffedFiles(commitSha) {
  const diffedFiles = await git.diff(["--name-only", `${commitSha}..HEAD`]);
  return R.split("\n", diffedFiles);
}

async function getDiffedPlugins(commitSha) {
  const diffedFiles = await getDiffedFiles(commitSha);

  return R.compose(
    R.uniq,
    R.map(R.compose(R.prop(1), R.split("/"))),
    R.filter(R.includes("plugins/"))
  )(diffedFiles);
}

function hasPluginChanged(latestTagSha) {
  return async function (pluginFolder) {
    try {
      const lastPluginCommit = await getLatestVersionSha(
        `plugins/${pluginFolder}`
      );
      const latestSha = lastPluginCommit || latestTagSha;
      const diffedPlugins = await getDiffedPlugins(latestSha);

      if (diffedPlugins.includes(pluginFolder)) {
        return await retriveNewPluginData({ pluginFolder, latestSha });
      } else {
        console.log(
          `plugin ${pluginFolder} hasn't changed since ${latestSha} - skipping`
        );
      }

      return null;
    } catch (e) {
      throw e;
    }
  };
}

function pluginPackageJson(pluginFolder) {
  return require(resolve(
    __dirname,
    "../plugins",
    pluginFolder,
    "package.json"
  ));
}

const commitMessagesContains = (str) =>
  R.compose(R.gt(R.__, 0), R.length, R.filter(R.includes(str)));

async function retriveNewPluginData({ pluginFolder, latestSha }) {
  const result = await exec(
    `git log ${latestSha}..HEAD --pretty=tformat:%s -- plugins/${pluginFolder}`
  );

  const currentVersion = pluginPackageJson(pluginFolder).version;
  const lastCommits = R.compose(R.reject(R.isEmpty), R.split("\n"))(result);

  const minor = commitMessagesContains("feat")(lastCommits);
  const major = commitMessagesContains("BREAKING CHANGE")(lastCommits);

  const release = major ? "major" : minor ? "minor" : "patch";

  const newVersion = semver.inc(currentVersion, release);
  const lastPluginCommit = await getLatestVersionSha(`plugins/${pluginFolder}`);

  console.log(`plugin to update ${pluginFolder} with ${newVersion}`);
  return { pluginFolder, newVersion };
}

async function retrieveDiffedPlugins() {
  console.log("#--------------------#");
  console.log("  Retrieve diffed plugins ");
  console.log("#--------------------#\n");

  try {
    const lastCommit = await getLastCommit();
    console.log("#--------------------", { lastCommit });

    if (lastCommit.includes("chore: publish")) {
      console.log("last commit is a publish commit - skipping");
      process.exit(0);
    }
    console.log("#--------------------#\n");

    const latestTag = await getLatestTag();
    console.log({ latestTag });

    const latestTagSha = await git.revparse(["--short", latestTag]);
    console.log({ latestTagSha });

    const pluginsDir = await readdirAsync(resolve(__dirname, "../plugins"));
    console.log({ pluginsDir });

    const isNotNil = R.compose(R.not, R.isNil);

    const result = await Promise.all(
      R.compose(
        R.map(hasPluginChanged(latestTagSha)),
        R.reject(R.anyPass([R.includes(".DS_Store")]))
      )(pluginsDir)
    );
    const filtered = R.filter(isNotNil)(result);

    return filtered;
  } catch (e) {
    console.log("An error occured to retrieve diffed items");
    console.error(e);
    process.exit(1);
  }
}

module.exports = { retrieveDiffedPlugins };

// async function run() {
//   await retrieveDiffedPlugins();
// }
// run();

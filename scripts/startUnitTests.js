#!/usr/bin/env node
/* eslint-disable no-console */
// const {
//   iosBuildUnitTests,
// } = require("@applicaster/zapplicaster-cli/publishPlugin/iOSTasks");
// const {
//   getIosModuleName,
// } = require("@applicaster/zapplicaster-cli/publishPlugin/iOSTasks/helper");

const {
  iosBuildUnitTests,
} = require("/Users/antonkononenko/Work3/QuickBrick/packages/zapplicaster-cli/publishPlugin/iOSTasks");

const {
  getIosModuleName,
} = require("/Users/antonkononenko/Work3/QuickBrick/packages/zapplicaster-cli/publishPlugin/iOSTasks/helper");

const { resolve } = require("path");
const rootPath = resolve(__dirname, "..");
const git = require("simple-git/promise")(rootPath);
const shelljs = require("shelljs");
const R = require("ramda");

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

async function invokeAppleUnitTests({ pluginFolder }) {
  let iosModuleName = await getIosModuleName(pluginFolder);

  try {
    const output = iosBuildUnitTests({ iosModuleName });
    return output;
  } catch (e) {
    throw e;
  }
}

async function run() {
  console.log("#--------------------#");
  console.log("  Starting Unit Test for Apple  ");
  console.log("#--------------------#\n");

  try {
    await exec("git checkout -- .");
    await exec("git clean -fd");

    const diffedPlugins = await retrieveDiffedPlugins();
    const result = await Promise.all(
      R.map(invokeAppleUnitTests)(diffedPlugins)
    );

    return result;
  } catch (e) {
    console.log(
      "An error occured while publishing plugins, please check the error below"
    );
    console.error(e);
    process.exit(1);
  }
}

run();

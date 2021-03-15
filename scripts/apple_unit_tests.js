#!/usr/bin/env node --login -eo pipefail

/* eslint-disable no-console */
const {
  iosBuildUnitTests,
} = require("./test_tasks");
const {
  getIosModuleName,
} = require("./test_tasks/helper");
const { existsSync } = require("fs");

const { resolve } = require("path");
const rootPath = resolve(__dirname, "..");
const git = require("simple-git/promise")(rootPath);
const shelljs = require("shelljs");
const R = require("ramda");

const { retrieveDiffedPlugins } = require("./get_changed_plugins");

async function invokeAppleUnitTests({ pluginFolder }) {
  const pluginPath = `plugins/${pluginFolder}`;
  const iosPluginPath = `${pluginPath}/apple`;

  if (existsSync(iosPluginPath)) {
    let iosModuleName = await getIosModuleName({ pluginPath });

    try {
      const output = iosBuildUnitTests({ iosModuleName, pluginPath });
      return output;
    } catch (e) {
      throw e;
    }
  }
}

async function run() {
  console.log("#--------------------#");
  console.log("  Starting Unit Test for Apple  ");
  console.log("#--------------------#\n");

  try {
    const diffedPlugins = await retrieveDiffedPlugins();
    console.log({ diffedPlugins });
    const result = await Promise.all(
      R.map(invokeAppleUnitTests)(diffedPlugins)
    );

    return result;
  } catch (e) {
    console.log(
      "An error occured while start unit testing plugin, please check the error below"
    );
    console.error(e);
    process.exit(1);
  }
}

run();

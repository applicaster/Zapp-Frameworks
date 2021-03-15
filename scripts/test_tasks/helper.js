
const { existsSync, readdir } = require("fs");
const { promisify } = require("util");

const readdirAsync = promisify(readdir);
const podspecSuffix = ".podspec.json";

async function getIosModuleName({ pluginPath }) {
  const filePodspec = await getPodspecFile({
    pluginAppleFolder: `${pluginPath}/apple`,
  });

  if (filePodspec) {
    return filePodspec.replace(podspecSuffix, "");
  }

  return null;
}

async function getPodspecFile({ pluginAppleFolder }) {
  if (existsSync(pluginAppleFolder)) {
    const files = await readdirAsync(pluginAppleFolder);

    for (let i in files) {
      const currentPath = files[i];

      if (currentPath && currentPath.endsWith(podspecSuffix)) {
        return currentPath;
      }
    }
  }

  return null;
}

async function getPodspecFilePath({ pluginAppleFolder }) {
  const fileName = await getPodspecFile({ pluginAppleFolder });

  if (fileName && fileName.endsWith(podspecSuffix)) {
    return `${pluginAppleFolder}/${fileName}`;
  }
}

function abort(message) {
  console.log(message);
  process.exit(1);
}

module.exports = {
  abort,
  getPodspecFilePath,
  getIosModuleName,
};

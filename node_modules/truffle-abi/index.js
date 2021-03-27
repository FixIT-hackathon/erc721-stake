#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const _ = require("lodash");
const minimist = require("minimist");
const winston = require("winston");

const logger = winston.createLogger({
  levels: winston.config.syslog.levels,
  level: "notice",
  format: winston.format.simple(),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

function exportAbiForFile(filename) {
  if (filename.endsWith(".json")) {
    const data = fs.readFileSync(filename);
    const jsonData = JSON.parse(data);
    if (jsonData.hasOwnProperty("abi")) {
      logger.info("read: " + filename);
      return jsonData["abi"];
    }
  }
  return null;
}

function exportAbiForDirectory(directory) {
  var res = [];
  const fileList = fs.readdirSync(directory);
  logger.info("looking for json files in: " + directory);
  fileList.forEach(filename => {
    jsonAbi = exportAbiForFile(path.join(directory, filename));
    if (jsonAbi !== null) {
      res = _.union(res, jsonAbi);
    }
  });
  return res;
}

function printHelp() {
  console.log(
    "Example: " +
      process.argv[1] +
      " -d /home/user/myproject/build/contracts/ -v\n" +
      "Options:\n" +
      "   -d / --directory: location of the build files, [build/contracts] by default\n" +
      "   -o / --output: output directory, [abi/] by default\n" +
      "   -v / --verbose"
  );
}

function main() {
  var args = minimist(process.argv.slice(2), {
    alias: { d: "directory", v: "verbose", o: "output" },
    boolean: ["verbose"],
    default: { d: "build/contracts", o: "build/abi" }
  });
  if (args.verbose) {
    logger.level = "info";
  }
  fs.stat(args.directory, (err, stats) => {
    if (!err && stats.isDirectory()) {
      //abi = exportAbiForDirectory(args.directory);
      const fileList = fs.readdirSync(args.directory);
      logger.info("looking for json files in: " + args.directory);
      if (!fs.existsSync(args.output)){
        fs.mkdirSync(args.output);
      }
      fileList.forEach(filename => {
        let jsonAbi = exportAbiForFile(path.join(args.directory, filename));
        if (jsonAbi !== null) {
          let outputFile = path.join(args.output, filename);
          fs.writeFileSync(outputFile, JSON.stringify(jsonAbi, null, 2));
          logger.notice("abi -> " + outputFile);           
        }
      });
      logger.notice("Done!");

    } else {
      logger.error(
        '"' +
          args.directory +
          '" must be a directory, you might need the -d or --directory argument'
      );
      printHelp();
      process.exit(2);
    }
  });
}

main();

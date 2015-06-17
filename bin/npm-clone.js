#!/usr/bin/env node

process.title = 'npm-clone';

var argv = require('minimist')(process.argv.slice(2));
require('../lib/cli')(argv, function(err) {
  if (err) {
    console.error(err.stack || err);
    process.exit(1);
  }
  process.exit(0);
});


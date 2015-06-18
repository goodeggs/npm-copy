path = require 'path'
fs = require 'fs'
fibrous = require 'fibrous'
RegClient = require 'npm-registry-client'

module.exports = fibrous (argv) ->

  from =
    url: argv.from
    auth:
      token: argv['from-token']
      username: argv['from-username']
      password: argv['from-password']
      alwaysAuth: true

  moduleNames = argv._

  unless from.url and (from.auth.token or (from.auth.username and from.auth.password)) and moduleNames.length
    console.log 'usage: npm-clone --from <repository url> --from-token <token> --to <repository url> --to-token <token> moduleA [moduleB...]'
    return

  npm = new RegClient()

  for moduleName in argv._
    moduleData = npm.sync.get "#{from.url}/#{moduleName}", auth: from.auth, timeout: 3000

    for semver, oldMetadata of moduleData.versions
      {dist} = oldMetadata

      # clone the metadata skipping private properties and 'dist'
      newMetadata = {}
      newMetadata[k] = v for k, v of oldMetadata when k[0] isnt '_' and k isnt 'dist'

      remoteTarball = npm.sync.fetch dist.tarball, auth: from.auth

      localTarball = fs.createWriteStream path.resolve(path.basename(dist.tarball))
      remoteTarball.pipe(localTarball)
      localTarball.sync.on 'close'

      console.log [moduleName, semver, dist.tarball, dist.shasum].join "\t"
      break # just do the first one


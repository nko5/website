spawn = require('child_process').spawn
path = require('path')

rootDir = path.join(__dirname, '..', '..')

module.exports = setupRepo = (options, next) ->
  team = options.team

  console.log team.slug, 'setup repo'
  createRepo = spawn path.join(__dirname, './setup-repo.sh'),
    [ team.slug, team.code, team.name, team.ip ],
    stdio: 'inherit',
    cwd: rootDir
  createRepo.on 'error', (err) -> next(err)
  createRepo.on 'exit', (err) -> next(err)

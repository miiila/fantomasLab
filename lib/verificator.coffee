class Result
  @success
  @location
  @type

cmlDependentLocations = ['2_a_4','2_b_1','2_c_4','2_d_1','3_a_4','3_b_1','3_c_4','3_d_1']

verifyCode = (code) ->
  codes = require('../files/codes.json')
  return codes[code] ? false

loadTaskInfo = (taskCode) ->
  tasks = require('../files/tasks.json')
  task.desc for task in tasks when task.code == taskCode

module.exports.parseCommand = (command) ->
  result = new Result()
  parsedCommand = command.split(' ')
  switch  parsedCommand[0]
    when 'open'
      result.type = 'open'
      location = verifyCode(parsedCommand[1])
      if location
        result.location = location
        result.success = true
      else
        result.success = false
    when 'cml'
      result.type = 'system'
      result.command = parsedCommand[1]
      result.success = if parsedCommand[1] == 'shutdown' then true else false
      result.locations = cmlDependentLocations
    when 'view'
      result.type = 'view'
      result.taskName = parsedCommand[1]
      info = loadTaskInfo(parsedCommand[1])
      result.success = if info? then true else false
      result.info = info
  return result
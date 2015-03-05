fs = require('fs')
class Result
  @success
  @location
  @type

#puzzleLocations = ['2_a_1','2_a_2','2_a_3','2_b_2','2_b_3','2_b_4','2_c_1','2_c_2','2_c_3','2_d_2','2_d_3','2_d_4','3_a_1','3_a_2','3_a_3','3_b_2','3_b_3','3_b_4','3_c_1','3_c_2','3_c_3','3_d_2','3_d_3','3_d_4']
puzzleLocations = ['2_a_3','2_b_2','2_c_3']
cmlDependentLocations = ['2_a_4','2_b_1','2_c_4','2_d_1','3_a_4','3_b_1','3_c_4','3_d_1']

verifyCode = (code) ->
  codes = readJson("./files/codes.json")
  return codes[code] ? false

loadTaskInfo = (taskCode) ->
  tasks = module.exports.getTasks()
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
        puzzleLocations = (puzzleLocation for puzzleLocation in puzzleLocations when puzzleLocation != location)
        result.finished = true if isFinished()
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
      result.success = if info?.length then true else false
      result.info = info
  return result

module.exports.getTasks = ->
  readJson("./files/tasks.json")

readJson = (path) ->
  JSON.parse(fs.readFileSync(path)) if fs.existsSync(path)

isFinished = ->
  puzzleLocations.length == 0

module.exports.resetPuzzleLocations = ->
  puzzleLocations = ['2_a_3','2_b_2','2_c_3']


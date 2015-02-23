class Result
  @success
  @location
  @type

codes = {
  'jahoda':'echo',
  'boruvka':'golf',
  'malina':'hotel'}

cmlDependentLocations = ['1_a_1','1_b_1','1_c_1','1_d_1','2_a_1','2_b_1','2_c_1','2_d_1']

verifyCode = (code) ->
  return codes[code] ? false


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
  return result
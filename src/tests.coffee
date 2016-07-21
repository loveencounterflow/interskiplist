


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'INTERSKIPLIST/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
ISL                       = require './main'

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  test @, 'timeout': 3000

#-----------------------------------------------------------------------------------------------------------
hex = ( n ) -> '0x' + n.toString 16

#-----------------------------------------------------------------------------------------------------------
find_id_text = ( me, probe ) ->
  R = ISL.find_any_ids me, probe
  R.sort()
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
show = ( me ) ->
  echo '  0         1         2         3         4         5         6         7         8         '
  echo '  012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
  for id, [ lo, hi, ] of ISL.get_intervals me
    [ lo, hi, ] = [ hi, lo, ] if lo > hi
    if lo is hi
      echo id, ( ' '.repeat lo ) + 'H'
      continue
    echo id, ( ' '.repeat lo ) + '[' + ( '-'.repeat hi - lo - 1 ) + ']'


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "test interval tree 1" ] = ( T ) ->
  #.........................................................................................................
  isl  = ISL.new()
  intervals = [
    [  1,  3, 'A',  ]
    [  2, 14, 'B',  ]
    [  3,  7, 'C',  ]
    [  4,  4, 'D',  ]
    [  5,  7, 'E',  ]
    [  8, 12, 'F1', ]
    [  8, 12, 'F2', ]
    [  8, 22, 'G',  ]
    [ 10, 13, 'H',  ]
    ]
  #.........................................................................................................
  for [ lo, hi, id, value, ] in intervals
    ISL.add_interval isl, lo, hi, id, value
  show isl
  #.........................................................................................................
  # search()
  T.eq ( find_id_text isl,  0 ), ''
  T.eq ( find_id_text isl,  1 ), 'A'
  T.eq ( find_id_text isl,  2 ), 'A,B'
  T.eq ( find_id_text isl,  3 ), 'A,B,C'
  T.eq ( find_id_text isl,  4 ), 'B,C,D'
  T.eq ( find_id_text isl,  5 ), 'B,C,E'
  T.eq ( find_id_text isl,  6 ), 'B,C,E'
  T.eq ( find_id_text isl,  7 ), 'B,C,E'
  T.eq ( find_id_text isl,  8 ), 'B,F1,F2,G'
  T.eq ( find_id_text isl,  9 ), 'B,F1,F2,G'
  T.eq ( find_id_text isl, 10 ), 'B,F1,F2,G,H'
  T.eq ( find_id_text isl, 11 ), 'B,F1,F2,G,H'
  T.eq ( find_id_text isl, 12 ), 'B,F1,F2,G,H'
  T.eq ( find_id_text isl, 13 ), 'B,G,H'
  T.eq ( find_id_text isl, 14 ), 'B,G'
  T.eq ( find_id_text isl, 15 ), 'G'
  T.eq ( find_id_text isl, 16 ), 'G'
  T.eq ( find_id_text isl, 17 ), 'G'
  T.eq ( find_id_text isl, 18 ), 'G'
  # ISL.add_interval isl, [ 10, 13, 'FF' ]
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test interval tree 2" ] = ( T ) ->
  isl      = ISL.new()
  intervals = [
    [ 17, 19, 'A', ]
    [  5,  8, 'B', ]
    [ 21, 24, 'C', ]
    [  4,  8, 'D', ]
    [ 15, 18, 'E', ]
    [  7, 10, 'F', ]
    [ 16, 22, 'G', ]
    ]
  ISL.add_interval isl, interval... for interval in intervals
  show isl
  # ISL._decorate isl[ '%self' ][ 'root' ]
  # search()
  error_count = 0
  # error_count += eq ( find_id_text isl, 0 ), ''
  # debug rpr find_id_text isl, [ 23, 25, ] # 'C'
  # debug rpr find_id_text isl, [ 12, 14, ] # ''
  # debug rpr find_id_text isl, [ 21, 23, ] # 'G,C'
  debug rpr find_id_text isl, [  8,  9, ] # 'B,D,F'
  debug rpr find_id_text isl, [  5,  8, ]
  debug rpr find_id_text isl, [ 21, 24, ]
  debug rpr find_id_text isl, [  4,  8, ]
  # search()
  debug '4430', ISL.get_values isl
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  include = [
    "test interval tree 1"
    "test interval tree 2"
  ]
  # @_prune()
  @_main()

  # @[ "test interval tree 1" ]()
  # @[ "test interval tree 2" ]()



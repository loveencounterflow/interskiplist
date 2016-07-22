


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
find_ids_text = ( me, points... ) ->
  R = ISL.find_ids_with_all_points me, points...
  R.sort()
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
find_names_text = ( me, points... ) ->
  # debug '8322', ISL.find_ids_with_all_points me, points...
  R = ISL.find_names_with_all_points me, points...
  R.sort()
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
show = ( me ) ->
  echo '                      0         1         2         3         4         5         6         7         8         '
  echo '                      012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
  for id, [ lo, hi, ] of ISL.intervals_of me
    lo_closed = yes
    hi_closed = yes
    # [ lo, hi, ] = [ hi, lo, ] if lo > hi
    if lo < 0
      lo        = 0
      lo_closed = no
    if hi > 89
      hi        = 89
      hi_closed = no
    id += ' ' while id.length < 20
    if lo is hi
      echo id + '  ' + ( ' '.repeat lo ) + 'H'
      continue
    left  = if lo_closed then '[' else '-'
    right = if hi_closed then ']' else '-'
    echo id + '  ' + ( ' '.repeat lo ) + left + ( '-'.repeat hi - lo - 1 ) + right


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
  for [ lo, hi, id, ] in intervals
    ISL.insert isl, { lo, hi, id, }
  show isl
  #.........................................................................................................
  # search()
  T.eq ( find_ids_text isl,  0 ), ''
  T.eq ( find_ids_text isl,  1 ), 'A'
  T.eq ( find_ids_text isl,  2 ), 'A,B'
  T.eq ( find_ids_text isl,  3 ), 'A,B,C'
  T.eq ( find_ids_text isl,  4 ), 'B,C,D'
  T.eq ( find_ids_text isl,  5 ), 'B,C,E'
  T.eq ( find_ids_text isl,  6 ), 'B,C,E'
  T.eq ( find_ids_text isl,  7 ), 'B,C,E'
  T.eq ( find_ids_text isl,  8 ), 'B,F1,F2,G'
  T.eq ( find_ids_text isl,  9 ), 'B,F1,F2,G'
  T.eq ( find_ids_text isl, 10 ), 'B,F1,F2,G,H'
  T.eq ( find_ids_text isl, 11 ), 'B,F1,F2,G,H'
  T.eq ( find_ids_text isl, 12 ), 'B,F1,F2,G,H'
  T.eq ( find_ids_text isl, 13 ), 'B,G,H'
  T.eq ( find_ids_text isl, 14 ), 'B,G'
  T.eq ( find_ids_text isl, 15 ), 'G'
  T.eq ( find_ids_text isl, 16 ), 'G'
  T.eq ( find_ids_text isl, 17 ), 'G'
  T.eq ( find_ids_text isl, 18 ), 'G'
  # ISL.insert isl, [ 10, 13, 'FF' ]
  # delete isl[ '%self' ]
  # debug '©29478', isl
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test interval tree 2" ] = ( T ) ->
  #.........................................................................................................
  isl  = ISL.new()
  intervals = [
    [   1,  3,  'orion' ]
    [   2, 14,  'orion' ]
    [   3,  7,  'orion' ]
    [   4,  4,  'orion' ]
    [   5,  7,  'cygnus' ]
    [   5,  7,  'orion' ]
    [   8, 12,  'aldebaran' ]
    [ -12,  8,  'aldebaran' ]
    [   8, 22,  'aldebaran' ]
    [  10, 13,  'aldebaran' ]
    [  11, 15,  'cygnus' ]
    ]
  #.........................................................................................................
  for [ lo, hi, name, ] in intervals
    ISL.insert isl, { lo, hi, name, }
  show isl
  #.........................................................................................................
  T.eq ( find_names_text isl,  0 ), "aldebaran"
  T.eq ( find_names_text isl,  1 ), "aldebaran,orion"
  T.eq ( find_names_text isl,  2 ), "aldebaran,orion"
  T.eq ( find_names_text isl,  3 ), "aldebaran,orion"
  T.eq ( find_names_text isl,  4 ), "aldebaran,orion"
  T.eq ( find_names_text isl,  5 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl,  6 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl,  7 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl,  8 ), "aldebaran,orion"
  T.eq ( find_names_text isl,  9 ), "aldebaran,orion"
  T.eq ( find_names_text isl, 10 ), "aldebaran,orion"
  T.eq ( find_names_text isl, 11 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl, 12 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl, 13 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl, 14 ), "aldebaran,cygnus,orion"
  T.eq ( find_names_text isl, 15 ), "aldebaran,cygnus"
  T.eq ( find_names_text isl, 16 ), "aldebaran"
  T.eq ( find_names_text isl, 17 ), "aldebaran"
  T.eq ( find_names_text isl, 18 ), "aldebaran"
  #.........................................................................................................
  # debug JSON.stringify find_names_text isl,  0
  # debug JSON.stringify find_names_text isl,  1
  # debug JSON.stringify find_names_text isl,  2
  # debug JSON.stringify find_names_text isl,  3
  # debug JSON.stringify find_names_text isl,  4
  # debug JSON.stringify find_names_text isl,  5
  # debug JSON.stringify find_names_text isl,  6
  # debug JSON.stringify find_names_text isl,  7
  # debug JSON.stringify find_names_text isl,  8
  # debug JSON.stringify find_names_text isl,  9
  # debug JSON.stringify find_names_text isl, 10
  # debug JSON.stringify find_names_text isl, 11
  # debug JSON.stringify find_names_text isl, 12
  # debug JSON.stringify find_names_text isl, 13
  # debug JSON.stringify find_names_text isl, 14
  # debug JSON.stringify find_names_text isl, 15
  # debug JSON.stringify find_names_text isl, 16
  # debug JSON.stringify find_names_text isl, 17
  # debug JSON.stringify find_names_text isl, 18
  #.........................................................................................................
  # delete isl[ '%self' ]
  # debug '©29478', isl
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "test interval tree 3" ] = ( T ) ->
  isl      = ISL.new()
  intervals = [
    [ 17, 19, 'plane', 'A', ]
    [  5,  8, 'plane', 'B', ]
    [ 21, 24, 'block', 'A', ]
    [  4,  8, 'block', 'D', ]
    ]
  ISL.insert isl, { lo, hi, type, name, } for [ lo, hi, type, name, ] in intervals
  show isl
  # ISL._decorate isl[ '%self' ][ 'root' ]
  # search()
  error_count = 0
  # error_count += eq ( find_ids_text isl, 0 ), ''
  # debug rpr find_ids_text isl, [ 23, 25, ] # 'C'
  # debug rpr find_ids_text isl, [ 12, 14, ] # ''
  # debug rpr find_ids_text isl, [ 21, 23, ] # 'G,C'
  # debug rpr find_ids_text isl, [  8,  9, ] # 'B,D,F'
  # debug rpr find_ids_text isl, [  5,  8, ]
  # debug rpr find_ids_text isl, [ 21, 24, ]
  # debug rpr find_ids_text isl, [  4,  8, ]
  debug ISL.find_entries_with_any_points isl, 18, 22
  debug ( entry for entry in ISL.find_entries_with_any_points isl, 18, 22 when entry[ 'type' ] is 'block' )
  # debug ISL.find_entries_with_all_points isl, [ 2, 30, ]
  # debug ISL.find_entries_with_any_points isl, 18
  # debug ISL.find_entries_with_all_points isl, 18
  # search()
  # debug '4430', ISL.get_values isl
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "preview: sort by size and insertion order" ] = ( T ) ->
  ###
  《 0x300a
  ###
  entries = [
    #.......................................................................................................
    {
      lo:         0x300a
      hi:         0x300a
      name:       'style:glyph-0x300a'
      rsg:        'u-cjk-sym'
      style:      { raise: -0.2 } }
    #.......................................................................................................
    {
      lo:         0x0
      hi:         0xffff
      name:       'plane:Basic Multilingual Plane (BMP)' }
    #.......................................................................................................
    {
      lo:         0x2e80
      hi:         0x33ff
      name:       'area:CJK Miscellaneous Area' }
    #.......................................................................................................
    {
      lo:         0x3000
      hi:         0x303f
      name:       'block:CJK Symbols and Punctuation'
      rsg:        'u-cjk-sym'
      is_cjk:     true
      tex:        'cnsymOld' }
    #.......................................................................................................
    {
      lo:         0x3000
      hi:         0x303f
      name:       'block:CJK Symbols and Punctuation'
      rsg:        'u-cjk-sym'
      is_cjk:     true
      tex:        'cnsymNew' }
    #.......................................................................................................
    {
      lo:         0x0
      hi:         0x10ffff
      name:       'style:fallback'
      tex:        'mktsRsgFb' }
    #.......................................................................................................
    ]
  #.........................................................................................................
  isl = ISL.new()
  ISL.insert isl, entry for entry in entries
  replacers =
    # rsg:    'skip'
    style:  'list'
    tex:    'list'
    rsg:    'assign'
    # style: ( facets ) ->
  entry = ISL.aggregate isl, ( '《'.codePointAt 0 ), replacers
  debug JSON.stringify entry
  help entry
  T.eq entry, {"tex":["mktsRsgFb","cnsymOld","cnsymNew"],"rsg":"u-cjk-sym","is_cjk":true,"style":[{"raise":-0.2}]}
  #.........................................................................................................
  return null



############################################################################################################
unless module.parent?
  include = [
    "test interval tree 1"
    "test interval tree 2"
    "test interval tree 3"
    "preview: sort by size and insertion order"
  ]
  # @_prune()
  @_main()

  # @[ "test interval tree 1" ]()
  # @[ "test interval tree 2" ]()

  ###
  isl = ISL.new()
  d = isl[ '%self' ]
  ISL.insert isl, id: 'A', lo: 3, hi: 6
  ISL.insert isl, id: 'B', lo: 9, hi: 10
  ISL.insert isl, id: 'C', lo: 5, hi: 10
  ISL.insert isl, id: 'D', lo: 2, hi: 15
  show isl
  debug d.findContaining 5
  debug d.findContaining 5, 6
  debug d.findContaining 5, 6, 7
  debug d.findContaining 5, 6, 7, 12
  # debug d.findIntersecting 5
  debug d.findIntersecting 5, 6
  debug d.findIntersecting 5, 6, 7
  debug d.findIntersecting 5, 6, 7, 12
  ###




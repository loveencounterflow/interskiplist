


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
find_ids_text = ( me, P... ) ->
  R = ISL.find_ids_with_all_points me, P...
  R.sort()
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
find_names_text = ( me, P... ) ->
  # debug '8322', ISL.find_ids_with_all_points me, P...
  R = ISL.find_names_with_all_points me, P...
  R.sort()
  return R.join ','

#-----------------------------------------------------------------------------------------------------------
list = ( me ) ->
  for entry in ISL.entries_of me
    [ type, _, ] = ( entry[ 'name' ] ? '???/' ).split ':'
    help ( CND.grey type + '/' ) + ( CND.steel 'interval' ) + ': ' + ( CND.yellow "#{hex entry[ 'lo' ]}-#{hex entry[ 'hi' ]}" )
    for key, value of entry
      # continue if key in [ 'lo', 'hi', 'id', ]
      help ( CND.grey type + '/' ) + ( CND.steel key ) + ': ' + ( CND.yellow value )
  return null

#-----------------------------------------------------------------------------------------------------------
show = ( me ) ->
  echo '                      0         1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         '
  echo '                      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'
  debug '4921', me[ 'min' ], me[ 'max' ]
  for id, [ lo, hi, ] of ISL.intervals_of me
    lo_closed = yes
    hi_closed = yes
    # [ lo, hi, ] = [ hi, lo, ] if lo > hi
    if lo < 0
      lo        = 0
      lo_closed = no
    if hi > 199
      hi        = 199
      hi_closed = no
    id += ' ' while id.length < 20
    if lo > 199 and hi > 199
      echo id id + '  ' + ( ' '.repeat 199 ) + '->'
      continue
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
  debug ISL.find_entries_with_any_points isl, [ 18, 22, ]
  debug ( entry for entry in ISL.find_entries_with_any_points isl, [ 18, 22, ] when entry[ 'type' ] is 'block' )
  # debug ISL.find_entries_with_all_points isl, [ 2, 30, ]
  # debug ISL.find_entries_with_any_points isl, 18
  # debug ISL.find_entries_with_all_points isl, 18
  # search()
  # debug '4430', ISL.get_values isl
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "new API for points" ] = ( T ) ->
  isl      = ISL.new()
  intervals = [
    [ 17, 19, 'plane', 'A', ]
    [  5,  8, 'plane', 'B', ]
    [ 21, 24, 'block', 'A', ]
    [  4,  8, 'block', 'D', ]
    ]
  ISL.insert isl, { lo, hi, type, name, } for [ lo, hi, type, name, ] in intervals
  ( ISL.find_ids_with_any_points isl, 7      )
  ( ISL.find_ids_with_any_points isl, [ 7, ] )
  ( ISL.find_ids_with_any_points isl, [ 7, 8, ] )
  T.throws 'expected 2 arguments, got 3', -> ISL.find_ids_with_any_points isl, 7, 8
  T.throws 'expected 2 arguments, got 3', -> ISL.find_ids_with_all_points isl, 7, 8
  T.throws 'expected a POD for reducer, got a number', -> ISL.aggregate isl, 7, 8
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "aggregation" ] = ( T ) ->
  ###
  《 0x300a
  ###
  entries = [
    #.......................................................................................................
    {
      lo:         0x300a
      hi:         0x300a
      type:       'style'
      name:       'glyph-0x300a'
      rsg:        'u-cjk-sym'
      style:      { raise: -0.2 } }
    #.......................................................................................................
    {
      lo:         0x0
      hi:         0xffff
      type:       'plane'
      name:       'Basic Multilingual Plane (BMP)' }
    #.......................................................................................................
    {
      lo:         0x2e80
      hi:         0x33ff
      type:       'area'
      name:       'CJK Miscellaneous Area' }
    #.......................................................................................................
    {
      lo:         0x3000
      hi:         0x303f
      type:       'block'
      name:       'CJK Symbols and Punctuation'
      rsg:        'u-cjk-sym'
      is_cjk:     true
      tex:        'cnsymOld' }
    #.......................................................................................................
    {
      lo:         0x3000
      hi:         0x303f
      type:       'block'
      name:       'CJK Symbols and Punctuation'
      rsg:        'u-cjk-sym'
      is_cjk:     true
      tex:        'cnsymNew' }
    #.......................................................................................................
    {
      lo:         0x0
      hi:         0x10ffff
      type:       'style'
      name:       'fallback'
      tex:        'mktsRsgFb' }
    #.......................................................................................................
    ]
  #.........................................................................................................
  isl = ISL.new()
  ISL.insert isl, entry for entry in entries
  replacers =
    # rsg:    'skip'
    type:   'list'
    style:  'list'
    tex:    'list'
    rsg:    'assign'
    # style: ( facets ) ->
  entry = ISL.aggregate isl, ( '《'.codePointAt 0 ), replacers
  debug JSON.stringify entry
  help entry
  T.eq entry, {
    type: [ 'style', 'plane', 'area', 'block', 'block', 'style' ],
    name: 'glyph-0x300a',
    tex: [ 'mktsRsgFb', 'cnsymOld', 'cnsymNew' ],
    rsg: 'u-cjk-sym',
    is_cjk: true,
    style: [ { raise: -0.2 } ] }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "characters as points 1" ] = ( T ) ->
  a_cid = 'a'.codePointAt 0
  z_cid = 'z'.codePointAt 0
  #.........................................................................................................
  isl  = ISL.new()
  ISL.insert isl, { lo: a_cid, hi: z_cid, name: 'Basic Latin:Lower Case', }
  entry = ( ISL.entries_of isl )[ 0 ]
  T.eq entry[ 'lo'   ], a_cid
  T.eq entry[ 'hi'   ], z_cid
  T.eq isl[ 'min'  ],   a_cid
  T.eq isl[ 'max'  ],   z_cid
  T.eq isl[ 'fmin' ],   a_cid
  T.eq isl[ 'fmax' ],   z_cid
  #.........................................................................................................
  isl  = ISL.new()
  ISL.insert isl, { lo: 'a', hi: 'z', name: 'Basic Latin:Lower Case', }
  entry = ( ISL.entries_of isl )[ 0 ]
  T.eq entry[ 'lo'   ], a_cid
  T.eq entry[ 'hi'   ], z_cid
  T.eq isl[ 'min'  ],   a_cid
  T.eq isl[ 'max'  ],   z_cid
  T.eq isl[ 'fmin' ],   a_cid
  T.eq isl[ 'fmax' ],   z_cid
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "characters as points 2" ] = ( T ) ->
  a_cid = 'a'.codePointAt 0
  z_cid = 'z'.codePointAt 0
  A_cid = 'A'.codePointAt 0
  Z_cid = 'Z'.codePointAt 0
  c_cid = 'c'.codePointAt 0
  C_cid = 'C'.codePointAt 0
  #.........................................................................................................
  isl  = ISL.new()
  ISL.insert isl, { lo: a_cid, hi: z_cid, name: 'letter', }
  ISL.insert isl, { lo: A_cid, hi: Z_cid, name: 'letter', }
  ISL.insert isl, { lo: a_cid, hi: z_cid, name: 'lower', }
  ISL.insert isl, { lo: A_cid, hi: Z_cid, name: 'upper', }
  # #.........................................................................................................
  # debug '5201-1', rpr find_names_text isl, c_cid
  # debug '5201-2', rpr find_names_text isl, C_cid
  # debug '5201-3', rpr find_names_text isl, c_cid, C_cid
  # debug '5201-4', rpr find_names_text isl, C_cid, C_cid
  # debug '5201-5', rpr find_names_text isl, C_cid, A_cid
  # debug '5201-6', rpr find_names_text isl, c_cid, A_cid
  #.........................................................................................................
  T.eq ( find_names_text isl, [ c_cid         ] ), 'letter,lower'
  T.eq ( find_names_text isl, [ C_cid         ] ), 'letter,upper'
  T.eq ( find_names_text isl, [ c_cid, C_cid, ] ), 'letter'
  T.eq ( find_names_text isl, [ C_cid, C_cid, ] ), 'letter,upper'
  T.eq ( find_names_text isl, [ C_cid, A_cid, ] ), 'letter,upper'
  T.eq ( find_names_text isl, [ c_cid, A_cid, ] ), 'letter'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "characters as points 3" ] = ( T ) ->
  isl = ISL.new()
  ISL.insert isl, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
  ISL.insert isl, { lo: 'a', hi: 'z', name: 'letter', }
  ISL.insert isl, { lo: 'A', hi: 'Z', name: 'letter', }
  ISL.insert isl, { lo: 'a', hi: 'z', name: 'lower', }
  ISL.insert isl, { lo: 'A', hi: 'Z', name: 'upper', }
  #.........................................................................................................
  for chr in 'aeiouAEIOU'
    ISL.insert isl, { lo: chr, hi: chr, name: 'vowel', }
  for chr in 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    ISL.insert isl, { lo: chr, hi: chr, name: 'consonant', }
  for chr in '0123456789'
    ISL.insert isl, { lo: chr, hi: chr, name: 'digit', }
  #.........................................................................................................
  # list isl
  #.........................................................................................................
  T.eq ( find_names_text isl, [ 'c'     , ] ), 'basic-latin,consonant,letter,lower'
  T.eq ( find_names_text isl, [ 'C'     , ] ), 'basic-latin,consonant,letter,upper'
  T.eq ( find_names_text isl, [ 'c', 'C', ] ), 'basic-latin,consonant,letter'
  T.eq ( find_names_text isl, [ 'C', 'C', ] ), 'basic-latin,consonant,letter,upper'
  T.eq ( find_names_text isl, [ 'C', 'A', ] ), 'basic-latin,letter,upper'
  T.eq ( find_names_text isl, [ 'c', 'A', ] ), 'basic-latin,letter'
  T.eq ( find_names_text isl, [ 'A', 'e', ] ), 'basic-latin,letter,vowel'
  T.eq ( find_names_text isl, [ 'i', 'e', ] ), 'basic-latin,letter,lower,vowel'
  T.eq ( find_names_text isl, [ '2', 'e', ] ), 'basic-latin'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "intervals_from_points" ] = ( T ) ->
  isl = ISL.new()
  # debug ISL.intervals_from_points isl, Array.from 'abcefg'
  T.eq ( ISL.intervals_from_points isl, [ 3, 4, 5, ] ), [ { lo: 3, hi: 5, }, ]
  T.eq ( ISL.intervals_from_points isl, [ 3, 4, 5, 7, 8, 9, 10 ] ), [ { lo: 3, hi: 5, }, { lo: 7, hi: 10, }, ]
  T.eq ( ISL.intervals_from_points isl, [ 7, 10 ] ), [ { lo: 7, hi: 7, }, { lo: 10, hi: 10, }, ]
  A_cid = 'A'.codePointAt 0
  B_cid = 'B'.codePointAt 0
  C_cid = 'C'.codePointAt 0
  X_cid = 'X'.codePointAt 0
  Y_cid = 'Y'.codePointAt 0
  Z_cid = 'Z'.codePointAt 0
  T.eq ( ISL.intervals_from_points isl, Array.from 'CBABAXZY' ), [ { lo: A_cid, hi: C_cid, }, { lo: X_cid, hi: Z_cid, }, ]
  T.eq ( ISL.intervals_from_points isl, ( Array.from 'CBABAXZY' ), { name: 'foo', } ), [ { lo: A_cid, hi: C_cid, name: 'foo', }, { lo: X_cid, hi: Z_cid, name: 'foo', }, ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "readme example 1" ] = ( T ) ->
  isl = ISL.new()
  ISL.insert isl, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
  ISL.insert isl, { lo: 'a', hi: 'z', name: 'letter', }
  ISL.insert isl, { lo: 'A', hi: 'Z', name: 'letter', }
  ISL.insert isl, { lo: 'a', hi: 'z', name: 'lower', }
  ISL.insert isl, { lo: 'A', hi: 'Z', name: 'upper', }
  #.........................................................................................................
  for chr in 'aeiouAEIOU'
    ISL.insert isl, { lo: chr, hi: chr, name: 'vowel', }
  consonants = Array.from 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
  for interval in ISL.intervals_from_points isl, consonants, { name: 'consonant', }
    ISL.insert isl, interval
  digits = Array.from '0123456789'
  for interval in ISL.intervals_from_points isl, digits, { name: 'digit', }
    ISL.insert isl, interval
  #.........................................................................................................
  show isl
  #.........................................................................................................
  console.log ISL.find_names_with_all_points isl, [ 'c'     , ]
  console.log ISL.find_names_with_all_points isl, [ 'C'     , ]
  console.log ISL.find_names_with_all_points isl, [ 'c', 'C', ]
  console.log ISL.find_names_with_all_points isl, [ 'C', 'C', ]
  console.log ISL.find_names_with_all_points isl, [ 'C', 'A', ]
  console.log ISL.find_names_with_all_points isl, [ 'c', 'A', ]
  console.log ISL.find_names_with_all_points isl, [ 'A', 'e', ]
  console.log ISL.find_names_with_all_points isl, [ 'i', 'e', ]
  console.log ISL.find_names_with_all_points isl, [ '2', 'e', ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "readme example 2" ] = ( T ) ->
  samples = ISL.new()
  ISL.insert samples, { lo: 0x0000, hi: 0x10ffff, name: 'latin',     font_family: 'Arial',        }
  ISL.insert samples, { lo: 0x4e00, hi:   0x9fff, name: 'cjk',       font_family: 'Sun-ExtA',     }
  ISL.insert samples, { lo:   0x26, hi:     0x26, name: 'ampersand', font_family: 'Baskerville',  }
  debug ISL.find_names_with_all_points samples, 'A' # --> [ 'latin' ]
  debug ISL.find_names_with_all_points samples, '&' # --> [ 'latin', 'ampersand' ]
  debug ISL.find_names_with_all_points samples, '人' # --> [ 'latin', 'cjk' ]
  debug ISL.aggregate samples, 'A' #, { font_family: 'list', }
  debug ISL.aggregate samples, '&' #, { font_family: 'list', }
  debug ISL.aggregate samples, '人' #, { font_family: 'list', }

#-----------------------------------------------------------------------------------------------------------
@[ "intervals without ID, name" ] = ( T ) ->
  isl = ISL.new()
  ISL.insert isl, { lo: 'a', 'hi': 'z', }
  ISL.insert isl, { lo: 'a', 'hi': 'k', id:   'lower-half' }
  ISL.insert isl, { lo: 'l', 'hi': 'z', name: 'upper-half' }
  # debug JSON.stringify ISL.find_entries_with_any_points isl, [ 'c', 'm', ]
  T.eq ( ISL.find_entries_with_any_points isl, [ 'c', 'm', ] ), [
    {"lo":97,"hi":122,"idx":0,"id":"+[0]","name":"+","size":26},
    {"lo":97,"hi":107,"id":"lower-half","idx":1,"name":"+","size":11},
    {"lo":108,"hi":122,"name":"upper-half","idx":2,"id":"upper-half[0]","size":15}
  ]
  return null


############################################################################################################
unless module.parent?
  include = [
    "test interval tree 1"
    "test interval tree 2"
    "test interval tree 3"
    "aggregation"
    "characters as points 1"
    "characters as points 2"
    "characters as points 3"
    "intervals_from_points"
    "new API for points"
    "readme example 1"
    "readme example 2"
    "intervals without ID, name"
  ]
  @_prune()
  @_main()

  # @[ "new API for points" ]()






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
@_main = ( handler = null ) ->
  test @, 'timeout': 3000

#-----------------------------------------------------------------------------------------------------------
hex = ( n ) -> '0x' + n.toString 16
s   = ( x ) -> JSON.stringify x

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
  # debug '4921', me[ 'min' ], me[ 'max' ]
  for id, [ lo, hi, ] of me[ '%self' ].intervalsByMarker
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
    ISL.add isl, { lo, hi, id, }
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
  # ISL.add isl, [ 10, 13, 'FF' ]
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
    ISL.add isl, { lo, hi, name, }
  show isl
  #.........................................................................................................
  # T.eq ( find_names_text isl,  0 ), "aldebaran"
  # T.eq ( find_names_text isl,  1 ), "aldebaran,orion"
  # T.eq ( find_names_text isl,  2 ), "aldebaran,orion"
  # T.eq ( find_names_text isl,  3 ), "aldebaran,orion"
  # T.eq ( find_names_text isl,  4 ), "aldebaran,orion"
  # T.eq ( find_names_text isl,  5 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl,  6 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl,  7 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl,  8 ), "aldebaran,orion"
  # T.eq ( find_names_text isl,  9 ), "aldebaran,orion"
  # T.eq ( find_names_text isl, 10 ), "aldebaran,orion"
  # T.eq ( find_names_text isl, 11 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl, 12 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl, 13 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl, 14 ), "aldebaran,cygnus,orion"
  # T.eq ( find_names_text isl, 15 ), "aldebaran,cygnus"
  # T.eq ( find_names_text isl, 16 ), "aldebaran"
  # T.eq ( find_names_text isl, 17 ), "aldebaran"
  # T.eq ( find_names_text isl, 18 ), "aldebaran"
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
  ISL.add isl, { lo, hi, type, name, } for [ lo, hi, type, name, ] in intervals
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
  ISL.add isl, { lo, hi, type, name, } for [ lo, hi, type, name, ] in intervals
  ( ISL.find_ids_with_any_points isl, 7      )
  ( ISL.find_ids_with_any_points isl, [ 7, ] )
  ( ISL.find_ids_with_any_points isl, [ 7, 8, ] )
  T.throws 'expected 2 arguments, got 3', -> ISL.find_ids_with_any_points isl, 7, 8
  T.throws 'expected 2 arguments, got 3', -> ISL.find_ids_with_all_points isl, 7, 8
  T.throws 'expected a POD for reducer, got a number', -> ISL.aggregate isl, 7, 8
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "characters as points 1" ] = ( T ) ->
  a_cid = 'a'.codePointAt 0
  z_cid = 'z'.codePointAt 0
  #.........................................................................................................
  isl  = ISL.new()
  ISL.add isl, { lo: a_cid, hi: z_cid, name: 'Basic Latin:Lower Case', }
  entry = ( ISL.entries_of isl )[ 0 ]
  T.eq entry[ 'lo'   ], a_cid
  T.eq entry[ 'hi'   ], z_cid
  T.eq isl[ 'min'  ],   a_cid
  T.eq isl[ 'max'  ],   z_cid
  T.eq isl[ 'fmin' ],   a_cid
  T.eq isl[ 'fmax' ],   z_cid
  #.........................................................................................................
  isl  = ISL.new()
  ISL.add isl, { lo: 'a', hi: 'z', name: 'Basic Latin:Lower Case', }
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
  ISL.add isl, { lo: a_cid, hi: z_cid, name: 'letter', }
  ISL.add isl, { lo: A_cid, hi: Z_cid, name: 'letter', }
  ISL.add isl, { lo: a_cid, hi: z_cid, name: 'lower', }
  ISL.add isl, { lo: A_cid, hi: Z_cid, name: 'upper', }
  # #.........................................................................................................
  # debug '5201-1', rpr find_names_text isl, c_cid
  # debug '5201-2', rpr find_names_text isl, C_cid
  # debug '5201-3', rpr find_names_text isl, c_cid, C_cid
  # debug '5201-4', rpr find_names_text isl, C_cid, C_cid
  # debug '5201-5', rpr find_names_text isl, C_cid, A_cid
  # debug '5201-6', rpr find_names_text isl, c_cid, A_cid
  #.........................................................................................................
  # T.eq ( find_names_text isl, [ c_cid         ] ), 'letter,lower'
  # T.eq ( find_names_text isl, [ C_cid         ] ), 'letter,upper'
  # T.eq ( find_names_text isl, [ c_cid, C_cid, ] ), 'letter'
  # T.eq ( find_names_text isl, [ C_cid, C_cid, ] ), 'letter,upper'
  # T.eq ( find_names_text isl, [ C_cid, A_cid, ] ), 'letter,upper'
  # T.eq ( find_names_text isl, [ c_cid, A_cid, ] ), 'letter'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "characters as points 3" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
  ISL.add isl, { lo: 'a', hi: 'z', name: 'letter', }
  ISL.add isl, { lo: 'A', hi: 'Z', name: 'letter', }
  ISL.add isl, { lo: 'a', hi: 'z', name: 'lower', }
  ISL.add isl, { lo: 'A', hi: 'Z', name: 'upper', }
  #.........................................................................................................
  for chr in 'aeiouAEIOU'
    ISL.add isl, { lo: chr, hi: chr, name: 'vowel', }
  for chr in 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
    ISL.add isl, { lo: chr, hi: chr, name: 'consonant', }
  for chr in '0123456789'
    ISL.add isl, { lo: chr, hi: chr, name: 'digit', }
  #.........................................................................................................
  # list isl
  #.........................................................................................................
  # T.eq ( find_names_text isl, [ 'c'     , ] ), 'basic-latin,consonant,letter,lower'
  # T.eq ( find_names_text isl, [ 'C'     , ] ), 'basic-latin,consonant,letter,upper'
  # T.eq ( find_names_text isl, [ 'c', 'C', ] ), 'basic-latin,consonant,letter'
  # T.eq ( find_names_text isl, [ 'C', 'C', ] ), 'basic-latin,consonant,letter,upper'
  # T.eq ( find_names_text isl, [ 'C', 'A', ] ), 'basic-latin,letter,upper'
  # T.eq ( find_names_text isl, [ 'c', 'A', ] ), 'basic-latin,letter'
  # T.eq ( find_names_text isl, [ 'A', 'e', ] ), 'basic-latin,letter,vowel'
  # T.eq ( find_names_text isl, [ 'i', 'e', ] ), 'basic-latin,letter,lower,vowel'
  # T.eq ( find_names_text isl, [ '2', 'e', ] ), 'basic-latin'
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
@[ "intervals without ID, name" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 'a', 'hi': 'z', }
  ISL.add isl, { lo: 'a', 'hi': 'k', id:   'lower-half' }
  ISL.add isl, { lo: 'l', 'hi': 'z', name: 'upper-half' }
  # debug JSON.stringify ISL.find_entries_with_any_points isl, [ 'c', 'm', ]
  T.eq ( ISL.find_entries_with_any_points isl, [ 'c', 'm', ] ), [
    {"lo":97,"hi":122,"idx":0,"id":"+[0]","name":"+","size":26},
    {"lo":97,"hi":107,"id":"lower-half","idx":1,"name":"+","size":11},
    {"lo":108,"hi":122,"name":"upper-half","idx":2,"id":"upper-half[0]","size":15}
  ]
  return null


#-----------------------------------------------------------------------------------------------------------
@[ "aggregation 1" ] = ( T ) ->
  ###
  《 0x300a
  ###
  entries = [
    #.......................................................................................................
    {
      lo:         0x0
      hi:         0x10ffff
      type:       'style'
      name:       'fallback'
      tex:        'mktsRsgFb' }
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
      lo:         0x300a
      hi:         0x300a
      type:       'style'
      name:       'glyph-0x300a'
      rsg:        'u-cjk-sym'
      style:      { raise: -0.2 } }
    #.......................................................................................................
    ]
  #.........................................................................................................
  isl = ISL.new()
  ISL.add isl, entry for entry in entries
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
@[ "aggregation 2" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 0, hi: 10, id: 'wide',   count: 10, length: 10, foo: 'D',  }
  ISL.add isl, { lo: 3, hi:  7, id: 'narrow', count:  4, length:  4, foo: 'UH', }
  reducers =
    '*':    'list'
    id:     'include'
    lo:     'assign'
    hi:     'assign'
    name:   'assign'
    count:  'add'
    length: 'average'
    foo:    ( ids_and_values ) ->
      return ( ( value.toLowerCase() for [ id, value, ] in ids_and_values ). join '' ) + '!'
  debug JSON.stringify ISL.aggregate isl, 5, reducers
  T.eq ( ISL.aggregate isl, 5, reducers ), {"lo":3,"hi":7,"id":["wide","narrow"],"count":14,"name":"+","length":7,"foo":"duh!"}
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "readme example 1" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
  ISL.add isl, { lo: 'a', hi: 'z', name: 'letter', }
  ISL.add isl, { lo: 'A', hi: 'Z', name: 'letter', }
  ISL.add isl, { lo: 'a', hi: 'z', name: 'lower', }
  ISL.add isl, { lo: 'A', hi: 'Z', name: 'upper', }
  #.........................................................................................................
  for chr in 'aeiouAEIOU'
    ISL.add isl, { lo: chr, hi: chr, name: 'vowel', }
  consonants = Array.from 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
  for interval in ISL.intervals_from_points isl, consonants, { name: 'consonant', }
    ISL.add isl, interval
  digits = Array.from '0123456789'
  for interval in ISL.intervals_from_points isl, digits, { name: 'digit', }
    ISL.add isl, interval
  #.........................................................................................................
  show isl
  #.........................................................................................................
  # console.log ISL.find_names_with_all_points isl, [ 'c'     , ]
  # console.log ISL.find_names_with_all_points isl, [ 'C'     , ]
  # console.log ISL.find_names_with_all_points isl, [ 'c', 'C', ]
  # console.log ISL.find_names_with_all_points isl, [ 'C', 'C', ]
  # console.log ISL.find_names_with_all_points isl, [ 'C', 'A', ]
  # console.log ISL.find_names_with_all_points isl, [ 'c', 'A', ]
  # console.log ISL.find_names_with_all_points isl, [ 'A', 'e', ]
  # console.log ISL.find_names_with_all_points isl, [ 'i', 'e', ]
  # console.log ISL.find_names_with_all_points isl, [ '2', 'e', ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "readme example 2" ] = ( T ) ->
  samples = ISL.new()
  ISL.add samples, { lo: 0x0000, hi: 0x10ffff, name: 'base',      font_family: 'Arial',        }
  ISL.add samples, { lo:   0x00, hi:     0xff, name: 'ascii',     font_family: 'Arial',        }
  ISL.add samples, { lo: 0x4e00, hi:   0x9fff, name: 'cjk',       font_family: 'Sun-ExtA',     }
  ISL.add samples, { lo: 0x3040, hi:   0x309f, name: 'cjk',       font_family: 'Sun-ExtA',     }
  ISL.add samples, { lo:   0x26, hi:     0x26, name: 'ampersand', font_family: 'Baskerville',  }
  # debug 'rx2-1', 'A', ISL.find_names_with_all_points samples, 'A' # --> [ 'latin' ]
  # debug 'rx2-2', '&', ISL.find_names_with_all_points samples, '&' # --> [ 'latin', 'ampersand' ]
  # debug 'rx2-3', '人', ISL.find_names_with_all_points samples, '人' # --> [ 'latin', 'cjk' ]
  # debug 'rx2-3', 'Abcd人', ISL.find_names_with_all_points samples, Array.from 'Abcd人' # --> [ 'latin', 'cjk' ]
  # debug 'rx2-3', '人はるのそらのした', ISL.find_names_with_all_points samples, Array.from '人はるのそらのした' # --> [ 'latin', 'cjk' ]
  # T.eq ( ISL.find_names_with_all_points     samples, 'A' ), ( ISL.find_names     samples, 'A' )
  # T.eq ( ISL.find_names_with_all_points     samples, '&' ), ( ISL.find_names     samples, '&' )
  # T.eq ( ISL.find_names_with_all_points     samples, '人' ), ( ISL.find_names     samples, '人' )
  T.eq ( ISL.find_ids_with_all_points       samples, 'A' ), ( ISL.find_ids       samples, 'A' )
  T.eq ( ISL.find_ids_with_all_points       samples, '&' ), ( ISL.find_ids       samples, '&' )
  T.eq ( ISL.find_ids_with_all_points       samples, '人' ), ( ISL.find_ids       samples, '人' )
  # T.eq ( ISL.find_intervals_with_all_points samples, 'A' ), ( ISL.find_intervals samples, 'A' )
  # T.eq ( ISL.find_intervals_with_all_points samples, '&' ), ( ISL.find_intervals samples, '&' )
  # T.eq ( ISL.find_intervals_with_all_points samples, '人' ), ( ISL.find_intervals samples, '人' )
  # T.eq ( ISL.find_entries_with_all_points   samples, 'A' ), ( ISL.find_entries   samples, 'A' )
  # T.eq ( ISL.find_entries_with_all_points   samples, '&' ), ( ISL.find_entries   samples, '&' )
  # T.eq ( ISL.find_entries_with_all_points   samples, '人' ), ( ISL.find_entries   samples, '人' )
  urge 'rx2-7', 'A', ISL.aggregate samples, 'A' #, { font_family: 'list', }
  urge 'rx2-8', '&', ISL.aggregate samples, '&' #, { font_family: 'list', }
  urge 'rx2-9', '人', ISL.aggregate samples, '人' #, { font_family: 'list', }
  replacers = { '*': 'list', name: 'include', }
  info 'rx2-10', 'A', ISL.aggregate samples, 'A', replacers
  info 'rx2-11', '&', ISL.aggregate samples, '&', replacers
  info 'rx2-12', '人', ISL.aggregate samples, '人', replacers
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "preserve insertion order" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 10, hi: 20, id: 'foo',  name: 'alpha', }
  ISL.add isl, { lo: 15, hi: 25, id: 'bar',  name: 'beta', }
  ISL.add isl, { lo: 15, hi: 25, id: '22',   name: '0', }
  ISL.add isl, { lo: 19, hi: 29, id: 'baz',  name: 'beta', }
  ISL.add isl, { lo: 39, hi: 49, id: 'gnu',  name: 'gamma', }
  # info 'entry-by-ids: ', CND.rainbow isl[ 'entry-by-ids'  ]
  # info 'idx-by-names: ', CND.rainbow isl[ 'idx-by-names'  ]
  # info 'ids-by-names: ', CND.rainbow isl[ 'ids-by-names'  ]
  # info 'name-by-ids:  ', CND.rainbow isl[ 'name-by-ids'   ]
  # info 'idx-by-ids:   ', CND.rainbow isl[ 'idx-by-ids'    ]
  # debug JSON.stringify ISL.names_of isl, [ '22', 'foo', 'bar', ]
  # debug JSON.stringify ISL.names_of isl, [ 'foo', 'bar', '22', ]
  # debug JSON.stringify ISL.names_of isl, [ 'bar', '22', 'foo', ]
  # debug JSON.stringify ISL.names_of isl, [ 'bar', 'foo', '22', ]
  names_by_insertion_order = [ 'alpha', '0', 'beta', 'gamma' ]
  # T.eq ( ISL.names_of isl, [ '22', 'foo', 'bar', 'baz', 'gnu', ] ), names_by_insertion_order
  # T.eq ( ISL.names_of isl, [ 'foo', 'baz', 'gnu', 'bar', '22', ] ), names_by_insertion_order
  # T.eq ( ISL.names_of isl, [ 'baz', 'bar', '22', 'gnu', 'foo', ] ), names_by_insertion_order
  # T.eq ( ISL.names_of isl, [ 'bar', 'foo', 'baz', 'gnu', '22', ] ), names_by_insertion_order
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "demo discontiguous ranges" ] = ( T ) ->
  u = ISL.new()
  ISL.add u, { lo:  0x4e00,  hi:  0x9fff,  name: 'cjk', id: 'u-cjk',         }
  ISL.add u, { lo:  0xff00,  hi:  0xffef,  name: 'cjk', id: 'u-halfull',     }
  ISL.add u, { lo:  0x3400,  hi:  0x4dbf,  name: 'cjk', id: 'u-cjk-xa',      }
  ISL.add u, { lo: 0x20000,  hi: 0x2a6df,  name: 'cjk', id: 'u-cjk-xb',      }
  ISL.add u, { lo: 0x2a700,  hi: 0x2b73f,  name: 'cjk', id: 'u-cjk-xc',      }
  ISL.add u, { lo: 0x2b740,  hi: 0x2b81f,  name: 'cjk', id: 'u-cjk-xd',      }
  ISL.add u, { lo: 0x2b820,  hi: 0x2ceaf,  name: 'cjk', id: 'u-cjk-xe',      }
  ISL.add u, { lo:  0xf900,  hi:  0xfaff,  name: 'cjk', id: 'u-cjk-cmpi1',   }
  ISL.add u, { lo: 0x2f800,  hi: 0x2fa1f,  name: 'cjk', id: 'u-cjk-cmpi2',   }
  ISL.add u, { lo:  0x2f00,  hi:  0x2fdf,  name: 'cjk', id: 'u-cjk-rad1',    }
  ISL.add u, { lo:  0x2e80,  hi:  0x2eff,  name: 'cjk', id: 'u-cjk-rad2',    }
  ISL.add u, { lo:  0x3000,  hi:  0x303f,  name: 'cjk', id: 'u-cjk-sym',     }
  ISL.add u, { lo:  0x31c0,  hi:  0x31ef,  name: 'cjk', id: 'u-cjk-strk',    }
  ISL.add u, { lo:  0x30a0,  hi:  0x30ff,  name: 'cjk', id: 'u-cjk-kata',    }
  ISL.add u, { lo:  0x3040,  hi:  0x309f,  name: 'cjk', id: 'u-cjk-hira',    }
  ISL.add u, { lo:  0xac00,  hi:  0xd7af,  name: 'cjk', id: 'u-hang-syl',    }
  ISL.add u, { lo:  0x3200,  hi:  0x32ff,  name: 'cjk', id: 'u-cjk-enclett', }
  Array.from ''

#-----------------------------------------------------------------------------------------------------------
@[ "unique names with priority conflict" ] = ( T ) ->
  isl = ISL.new()
  ISL.add isl, { lo: 15, hi: 20, id: 'alpha-0',  name: 'alpha',  }
  ISL.add isl, { lo: 15, hi: 25, id: 'beta-0',   name: 'beta',   }
  ISL.add isl, { lo: 15, hi: 25, id: 'omega-0',  name: 'omega',  }
  ISL.add isl, { lo: 15, hi: 49, id: 'gamma-0',  name: 'gamma',  }
  ISL.add isl, { lo: 15, hi: 29, id: 'beta-1',   name: 'beta',   }
  show isl
  # debug '3928', JSON.stringify ISL.find_ids   isl, 15
  # debug '3928', JSON.stringify ISL.find_names isl, 15
  # urge '3928', JSON.stringify ISL.find_names_with_all_points isl, [ 15, 16, 30, ]
  # urge '3928', JSON.stringify ISL.find_names_with_any_points isl, [ 15, 16, 30, ]
  T.eq ( ISL.find_ids   isl, 15                              ), ["alpha-0","beta-0","omega-0","gamma-0","beta-1"]
  # T.eq ( ISL.find_names isl, 15                              ), ["alpha","omega","gamma","beta"]
  # T.eq ( ISL.find_names_with_all_points isl, [ 15, 16, 30, ] ), ["gamma"]
  # T.eq ( ISL.find_names_with_any_points isl, [ 15, 16, 30, ] ), ["alpha","omega","gamma","beta"]
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "tag 1" ] = ( T ) ->
  u = ISL.new()
  #.........................................................................................................
  ISL.add u, { lo: 0x00, hi: 0x7f, name: 'ascii', }
  for n in [ 0 .. 8 ] by +2
    digit_0 = "#{n}"
    digit_1 = "#{n + 1}"
    ISL.add u, { lo: digit_0, hi: digit_0, tag: [ 'ascii', 'digit', 'even', ], }
    ISL.add u, { lo: digit_1, hi: digit_1, tag: [ 'ascii', 'digit', 'odd',  ], }
  ISL.add u, { lo: '2', hi: '2', tag: [ 'prime', ], }
  ISL.add u, { lo: '3', hi: '3', tag: [ 'prime', ], }
  ISL.add u, { lo: '5', hi: '5', tag: [ 'prime', ], }
  ISL.add u, { lo: '7', hi: '7', tag: [ 'prime', ], }
  #.........................................................................................................
  for n in [ 0 .. 9 ]
    digit = "#{n}"
    help digit, ISL.aggregate u, digit, {
      '*':    'skip',
      tag:   'tag',
      }
  #.........................................................................................................
  T.eq ( ISL.aggregate u, '3', { '*': 'skip', tag: 'tag', } ), { tag: [ 'ascii', 'digit', 'odd', 'prime', ], }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "tag 2" ] = ( T ) ->
  u = ISL.new()
  #.........................................................................................................
  ISL.add u, { lo: 0x00, hi: 0x7f, name: 'ascii', }
  for n in [ 0 .. 8 ] by +2
    digit_0 = "#{n}"
    digit_1 = "#{n + 1}"
    ISL.add u, { lo: digit_0, hi: digit_0, tag: [ 'ascii', 'digit', 'even', ], }
    ISL.add u, { lo: digit_1, hi: digit_1, tag: [ 'ascii', 'digit', 'odd',  ], }
  ISL.add u, { lo: '2', hi: '2', tag: 'prime', }
  ISL.add u, { lo: '3', hi: '3', tag: 'prime', }
  ISL.add u, { lo: '5', hi: '5', tag: 'prime', }
  ISL.add u, { lo: '7', hi: '7', tag: 'prime', }
  #.........................................................................................................
  T.eq ( ISL.aggregate u, '3' ), { name: '+', tag: [ 'ascii', 'digit', 'odd', 'prime', ], }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "tag 2a" ] = ( T ) ->
  probes_and_matchers = [
    [ '0', { tag: [ 'digit', 'even' ] }, ]
    [ '1', { tag: [ 'digit', 'odd'  ] }, ]
    [ '2', { tag: [ 'digit', 'even' ] }, ]
    [ '3', { tag: [ 'digit', 'odd'  ] }, ]
    [ '4', { tag: [ 'digit', 'even' ] }, ]
    [ '5', { tag: [ 'digit', 'odd'  ] }, ]
    [ '6', { tag: [ 'digit', 'even' ] }, ]
    [ '7', { tag: [ 'digit', 'odd'  ] }, ]
    [ '8', { tag: [ 'digit', 'even' ] }, ]
    [ '9', { tag: [ 'digit', 'odd'  ] }, ]
    ]
  #.........................................................................................................
  u = ISL.new()
  #.........................................................................................................
  ISL.add u, { lo: 0x00, hi: 0x7f, name: 'ascii', }
  ISL.add u, { lo: '0', hi: '9', tag: [ 'digit', 'even', ], }
  for n in [ 1 .. 9 ] by +2
    digit_0 = "#{n}"
    ISL.add u, { lo: digit_0, hi: digit_0, tag: [ '-even', 'odd', ], }
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    result = ISL.aggregate u, probe, { name: 'skip', }
    # debug '0141', [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "tag 2b" ] = ( T ) ->
  probes_and_matchers = [
    [ '0', { tag: [ 'digit', 'even' ] }, ]
    [ '1', { tag: [ 'digit', 'odd'  ] }, ]
    [ '2', { tag: [ 'digit', 'even' ] }, ]
    [ '3', { tag: [ 'digit', 'odd'  ] }, ]
    [ '4', { tag: [ 'digit', 'even' ] }, ]
    [ '5', { tag: [ 'digit', 'odd'  ] }, ]
    [ '6', { tag: [ 'digit', 'even' ] }, ]
    [ '7', { tag: [ 'digit', 'odd'  ] }, ]
    [ '8', { tag: [ 'digit', 'even' ] }, ]
    [ '9', { tag: [ 'digit', 'odd'  ] }, ]
    ]
  #.........................................................................................................
  u = ISL.new()
  #.........................................................................................................
  ISL.add u, { lo: 0x00, hi: 0x7f, name: 'ascii', }
  ISL.add u, { lo: '0', hi: '9', tag: 'digit even', }
  for n in [ 1 .. 9 ] by +2
    digit_0 = "#{n}"
    ISL.add u, { lo: digit_0, hi: digit_0, tag: '-even odd', }
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    result = ISL.aggregate u, probe, { name: 'skip', }
    # debug '0141', [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "tag 3" ] = ( T ) ->
  u = ISL.new()
  #.........................................................................................................
  ISL.add u, { lo: 0x00, hi: 0x7f, tag:  'ascii', }
  ISL.add u, { lo: 0x00, hi: 0x7f, name: 'ascii-duplicate', }
  for n in [ 0 .. 8 ] by +2
    digit_0 = "#{n}"
    digit_1 = "#{n + 1}"
    ISL.add u, { lo: digit_0, hi: digit_0, tag: [ 'ascii', 'digit', 'even', ], }
    ISL.add u, { lo: digit_1, hi: digit_1, tag: [ 'ascii', 'digit', 'odd',  ], }
  ISL.add u, { lo: '2', hi: '2', tag: 'prime', }
  ISL.add u, { lo: '3', hi: '3', tag: 'prime', }
  ISL.add u, { lo: '5', hi: '5', tag: 'prime', }
  ISL.add u, { lo: '7', hi: '7', tag: 'prime', }
  #.........................................................................................................
  T.eq ( ISL.aggregate u, '3' ), { name: '+', tag: [ 'ascii', 'digit', 'odd', 'prime', ], }
  # debug '5531-6', s ISL.find_tags_with_all_points u, [ '3', '7', '2', ]
  # debug '5531-7', s ISL.find_tags_with_any_points u, [ '3', '7', '2', ]
  # T.eq ( ISL.find_tags u, '3' ), ["ascii","digit","odd","prime"]
  # T.eq ( ISL.find_tags_with_all_points u, [ '3', '7', '2', ] ), ["ascii","digit","prime"]
  # T.eq ( ISL.find_tags_with_any_points u, [ '3', '7', '2', ] ), ["even","ascii","digit","odd","prime"]
  #.........................................................................................................
  info u
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "configurable reducers, negative tags" ] = ( T ) ->
  #.........................................................................................................
  add = ( isl, description ) ->
    rsg = null
    tag = null
    [ type, tail..., ] = description
    #.......................................................................................................
    switch type
      when 'block'                then [ name, rsg, lo, hi, tag, ] = tail
      when 'plane', 'area'        then [ name,      lo, hi, tag, ] = tail
      when 'codepoints'           then [            lo, hi, tag, ] = tail
      else throw new Error "unknown entry type #{rpr type}"
    #.......................................................................................................
    interval            = { lo, hi, }
    interval[ type    ] = name                if name?
    interval[ 'rsg'   ] = rsg                 if rsg?
    interval[ 'tag'   ] = tag.split /[\s,]+/  if tag?
    ISL.add isl, interval
    #.......................................................................................................
    return null
  #.........................................................................................................
  descriptions = [
    #.......................................................................................................
    # Planes
    [ 'plane', 'Basic Multilingual Plane (BMP)',                               0x0000,    0xffff,  ]
    [ 'plane', 'Supplementary Multilingual Plane (SMP)',                      0x10000,   0x1ffff,  ]
    [ 'plane', 'Supplementary Ideographic Plane (SIP)',                       0x20000,   0x2ffff,  ]
    #.......................................................................................................
    # Areas
    [ 'area', 'ASCII & Latin-1 Compatibility Area',                           0x0000,     0x00ff,  ]
    [ 'area', 'General Scripts Area',                                         0x0100,     0x058f,  ]
    #.......................................................................................................
    # Blocks
    [ 'block', 'Basic Latin',                             'u-latn',               0x0,      0x7f,  ]
    [ 'block', 'Latin-1 Supplement',                      'u-latn-1',            0x80,      0xff,  ]
    [ 'block', 'Latin Extended-A',                        'u-latn-a',           0x100,     0x17f,  ]
    [ 'block', 'Latin Extended-B',                        'u-latn-b',           0x180,     0x24f,  ]
    [ 'block', 'IPA Extensions',                          'u-ipa-x',            0x250,     0x2af,  ]
    [ 'block', 'Armenian',                                null,                 0x530,     0x58f,  ]
    #.......................................................................................................
    [ 'block', 'CJK Unified Ideographs',                  'u-cjk',             0x4e00,    0x9fff, 'cjk ideograph', ]
    #.......................................................................................................
    [ 'block', 'CJK Unified Ideographs Extension A',      'u-cjk-xa',          0x3400,    0x4dbf, 'cjk ideograph', ]
    [ 'block', 'CJK Unified Ideographs Extension B',      'u-cjk-xb',         0x20000,   0x2a6df, 'cjk ideograph', ]
    [ 'block', 'CJK Unified Ideographs Extension C',      'u-cjk-xc',         0x2a700,   0x2b73f, 'cjk ideograph', ]
    [ 'block', 'CJK Unified Ideographs Extension D',      'u-cjk-xd',         0x2b740,   0x2b81f, 'cjk ideograph', ]
    [ 'block', 'CJK Unified Ideographs Extension E',      'u-cjk-xe',         0x2b820,   0x2ceaf, 'cjk ideograph', ]
    [ 'block', 'CJK Unified Ideographs Extension F',      'u-cjk-xf',         0x2ceb0,   0x2ebef, 'cjk ideograph', ]
    #.......................................................................................................
    [ 'block', 'Ideographic Description Characters',      'u-cjk-idc',         0x2ff0,    0x2fff, 'cjk idl', ]
    [ 'block', 'CJK Symbols and Punctuation',             'u-cjk-sym',         0x3000,    0x303f, 'cjk punctuation', ]
    [ 'block', 'CJK Strokes',                             'u-cjk-strk',        0x31c0,    0x31ef, 'cjk stroke', ]
    [ 'block', 'Enclosed CJK Letters and Months',         'u-cjk-enclett',     0x3200,    0x32ff, 'cjk', ]
    #.......................................................................................................
    [ 'block', 'Kangxi Radicals',                         'u-cjk-rad1',        0x2f00,    0x2fdf, 'cjk ideograph kxr', ]
    [ 'block', 'CJK Radicals Supplement',                 'u-cjk-rad2',        0x2e80,    0x2eff, 'cjk ideograph', ]
    #.......................................................................................................
    [ 'block', 'Hiragana',                                'u-cjk-hira',        0x3040,    0x309f, 'cjk japanese kana hiragana', ]
    [ 'block', 'Katakana',                                'u-cjk-kata',        0x30a0,    0x30ff, 'cjk japanese kana katakana', ]
    [ 'block', 'Kanbun',                                  'u-cjk-kanbun',      0x3190,    0x319f, 'cjk japanese kanbun', ]
    [ 'block', 'Katakana Phonetic Extensions',            'u-cjk-kata-x',      0x31f0,    0x31ff, 'cjk japanese kana katakana', ]
    #.......................................................................................................
    [ 'block', 'Hangul Jamo',                             'u-hang-jm',         0x1100,    0x11ff, 'cjk korean hangeul jamo', ]
    [ 'block', 'Hangul Syllables',                        'u-hang-syl',        0xac00,    0xd7af, 'cjk korean hangeul syllable', ]
    [ 'block', 'Hangul Jamo Extended-A',                  null,                0xa960,    0xa97f, 'cjk korean hangeul jamo', ]
    [ 'block', 'Hangul Jamo Extended-B',                  null,                0xd7b0,    0xd7ff, 'cjk korean hangeul jamo', ]
    #.......................................................................................................
    [ 'block', 'Bopomofo',                                'u-bopo',            0x3100,    0x312f, 'cjk bopomofo', ]
    [ 'block', 'Bopomofo Extended',                       'u-bopo-x',          0x31a0,    0x31bf, 'cjk bopomofo', ]
    #.......................................................................................................
    [ 'block', 'CJK Compatibility Forms',                 'u-cjk-cmpf',        0xfe30,    0xfe4f, 'cjk vertical', ]
    [ 'codepoints',                                                            0xfe45,    0xfe46, '-vertical', ]
    [ 'codepoints',                                                            0xfe49,    0xfe4f, '-vertical', ]
    [ 'block', 'Vertical Forms',                          'u-vertf',           0xfe10,    0xfe1f, 'cjk vertical', ]
    #.......................................................................................................
    [ 'block', 'Miscellaneous Symbols',                   'u-sym',             0x2600,    0x26ff, ]
    [ 'codepoints',                                                            0x262f,    0x2637, 'cjk' ]
    [ 'codepoints',                                                            0x2630,    0x2637, 'cjk yijing trigram' ]
    [ 'block', 'Yijing Hexagram Symbols',                 'u-yijng',           0x4dc0,    0x4dff, 'cjk yijing hexagram', ]
    [ 'block', 'Tai Xuan Jing Symbols',                   'u-txj-sym',        0x1d300,   0x1d35f, 'cjk yijing taixuanjing tetragram', ]
    [ 'codepoints',                                                           0x1d357,   0x1d35f, '-* reserved', ]
    #.......................................................................................................
    [ 'block', 'CJK Compatibility Ideographs',            'u-cjk-cmpi1',       0xf900,    0xfaff, 'cjk', ]
    [ 'block', 'Hangul Compatibility Jamo',               'u-hang-comp-jm',    0x3130,    0x318f, 'cjk', ]
    [ 'block', 'CJK Compatibility',                       'u-cjk-cmp',         0x3300,    0x33ff, 'cjk', ]
    [ 'block', 'CJK Compatibility Ideographs Supplement', 'u-cjk-cmpi2',      0x2f800,   0x2fa1f, 'cjk', ]
    #.......................................................................................................
    [ 'block', 'Private Use Area',                        'u-pua',             0xe000,    0xf8ff,  ]
    ]
  #.........................................................................................................
  probes_and_matchers = [
    ["a",{"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Basic Latin","rsg":"u-latn"}]
    ["ä",{"plane":"Basic Multilingual Plane (BMP)","area":"ASCII & Latin-1 Compatibility Area","block":"Latin-1 Supplement","rsg":"u-latn-1"}]
    ["ɐ",{"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"IPA Extensions","rsg":"u-ipa-x"}]
    ["ա",{"plane":"Basic Multilingual Plane (BMP)","area":"General Scripts Area","block":"Armenian"}]
    ["三",{"plane":"Basic Multilingual Plane (BMP)","block":"CJK Unified Ideographs","rsg":"u-cjk","tag":["cjk","ideograph"]}]
    ["ゆ",{"plane":"Basic Multilingual Plane (BMP)","block":"Hiragana","rsg":"u-cjk-hira","tag":["cjk","japanese","kana","hiragana"]}]
    ["㈪",{"plane":"Basic Multilingual Plane (BMP)","block":"Enclosed CJK Letters and Months","rsg":"u-cjk-enclett","tag":["cjk"]}]
    ["《",{"plane":"Basic Multilingual Plane (BMP)","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym","tag":["cjk","punctuation"]}]
    ["》",{"plane":"Basic Multilingual Plane (BMP)","block":"CJK Symbols and Punctuation","rsg":"u-cjk-sym","tag":["cjk","punctuation"]}]
    ["𫠠",{"plane":"Supplementary Ideographic Plane (SIP)","block":"CJK Unified Ideographs Extension E","rsg":"u-cjk-xe","tag":["cjk","ideograph"]}]
    ["﹄",{"plane":"Basic Multilingual Plane (BMP)","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf","tag":["cjk","vertical"]}]
    ["﹅",{"plane":"Basic Multilingual Plane (BMP)","block":"CJK Compatibility Forms","rsg":"u-cjk-cmpf","tag":["cjk"]}]
    ["𝍖",{"plane":"Supplementary Multilingual Plane (SMP)","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym","tag":["cjk","yijing","taixuanjing","tetragram"]}]
    [ ( String.fromCodePoint 0x1d357 ),{"plane":"Supplementary Multilingual Plane (SMP)","block":"Tai Xuan Jing Symbols","rsg":"u-txj-sym","tag":["reserved"]}]
    ]
  #.........................................................................................................
  tag_reducer = ( ids_and_tags ) ->
  u = ISL.new reducers: { name: 'skip', }
  for description in descriptions
    add u, description
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    help s [ probe, ISL.aggregate u, probe ]
    T.eq ( ISL.aggregate u, probe ), matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "_complements" ] = ( T ) ->
  ###
      0                   1                   2                   3                   4
  -∞  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 +∞

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                               [13---17]
  ---------------------10]                   [20---------------30]                   [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
           [3-----7]
  --------3]       [7--10]                   [20---------------30]                   [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                   [7--------13]
  ----------------7]                         [20---------------30]                   [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                                       [17-------23]
  ---------------------10]                         [23---------30]                   [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                                       [17---------------------------33]
  ---------------------10]                                                           [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                   [7----------------------------23]
  ----------------7]                               [23---------30]                   [40-------

  =============================================================================================
  ---------------------10]                   [20---------------30]                   [40-------
                   [7--------------------------------------------------------------------43]
  ----------------7]                                                                       [43-

  ###
  #.........................................................................................................
  f = ->
    @complement_from_intervals = ( me, intervals ) ->
      R     = []
      base  = { lo: Number.MIN_VALUE, hi: Number.MAX_VALUE, }
      isl   = @new()
      ISL.add isl, base
      if intervals.length is 0
        R.push base
      else
        for interval in intervals
          null
      return R
  #.........................................................................................................
  f.apply ISL
  #.........................................................................................................
  cleanup = ( intervals ) ->
    for interval in intervals
      delete interval[ 'id'     ]
      delete interval[ 'name'   ]
      delete interval[ 'idx'    ]
      delete interval[ 'size'   ]
    return intervals
  #.........................................................................................................
  probe   = []
  result  = cleanup ISL.complement_from_intervals null, probe
  T.eq result, [ { lo: Number.MIN_VALUE, hi: Number.MAX_VALUE, }, ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "infinity is a valid number" ] = ( T ) ->
  r = ISL.new()
  ISL.add r, lo: -Infinity, hi: +Infinity, tag: 'all'
  ISL.add r, lo:      -1e6, hi:      +1e6, tag: 'finite'
  ISL.add r, lo:      -1e5, hi:      +1e5, tag: 'truly-huge'
  ISL.add r, lo:      -1e4, hi:      +1e4, tag: 'huge'
  ISL.add r, lo:      -1e3, hi:      +1e3, tag: 'big'
  ISL.add r, lo:      -1e2, hi:      +1e2, tag: 'sizable'
  ISL.add r, lo:      -1e1, hi:      +1e1, tag: 'small'
  ISL.add r, lo:      -1e0, hi:      +1e0, tag: 'tiny'
  # debug s ( ISL.aggregate r,        1, { name: 'skip', } )
  # debug s ( ISL.aggregate r,       10, { name: 'skip', } )
  # debug s ( ISL.aggregate r,      100, { name: 'skip', } )
  # debug s ( ISL.aggregate r,     1000, { name: 'skip', } )
  # debug s ( ISL.aggregate r,    10000, { name: 'skip', } )
  # debug s ( ISL.aggregate r,   100000, { name: 'skip', } )
  # debug s ( ISL.aggregate r,  1000000, { name: 'skip', } )
  # debug s ( ISL.aggregate r, Infinity, { name: 'skip', } )
  T.eq ( ISL.aggregate r,        1, { name: 'skip', } ), {"tag":["all","finite","truly-huge","huge","big","sizable","small","tiny"]}
  T.eq ( ISL.aggregate r,       10, { name: 'skip', } ), {"tag":["all","finite","truly-huge","huge","big","sizable","small"]}
  T.eq ( ISL.aggregate r,      100, { name: 'skip', } ), {"tag":["all","finite","truly-huge","huge","big","sizable"]}
  T.eq ( ISL.aggregate r,     1000, { name: 'skip', } ), {"tag":["all","finite","truly-huge","huge","big"]}
  T.eq ( ISL.aggregate r,    10000, { name: 'skip', } ), {"tag":["all","finite","truly-huge","huge"]}
  T.eq ( ISL.aggregate r,   100000, { name: 'skip', } ), {"tag":["all","finite","truly-huge"]}
  T.eq ( ISL.aggregate r,  1000000, { name: 'skip', } ), {"tag":["all","finite"]}
  ### This is a glitch: interval boundaries should be inclusive, but apparentl<y `Infinity` is not
  within the boundaries of the interval with `hi: +Infinity`: ###
  T.eq ( ISL.aggregate r, Infinity, { name: 'skip', } ), {}
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "(v3) cover, intersect" ] = ( T ) ->
  ascii = ISL.new()
  ISL.add ascii, { lo: 0x00, hi: 0x7f, name: 'basic-latin', tag: 'basic-latin',   }
  ISL.add ascii, { lo: 'a',  hi: 'z',  name: 'letter',      tag: 'letter',        }
  ISL.add ascii, { lo: 'A',  hi: 'Z',  name: 'letter',      tag: 'letter',        }
  ISL.add ascii, { lo: 'a',  hi: 'z',  name: 'lower',       tag: 'lower',         }
  ISL.add ascii, { lo: 'A',  hi: 'Z',  name: 'upper',       tag: 'upper',         }
  #.........................................................................................................
  for chr in 'aeiouAEIOU'
    ISL.add ascii, { lo: chr, hi: chr, name: 'vowel', tag: 'vowel', }
  consonants = Array.from 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
  for interval in ISL.intervals_from_points ascii, consonants, { name: 'consonant', tag: 'consonant', }
    ISL.add ascii, interval
  digits = Array.from '0123456789'
  for interval in ISL.intervals_from_points ascii, digits, { name: 'digit', tag: 'digit', }
    ISL.add ascii, interval
  #.........................................................................................................
  show ascii
  #.........................................................................................................
  info ISL.cover ascii, 'f'
  info ISL.cover ascii, [ 'f', 'F', ]
  info ISL.cover ascii, [ 'f', 'F', ], pick: 'id'
  info ISL.aggregate ascii, [ 'f', 'F', ]
  info ISL.aggregate ascii, [ 'f', 'F', ], { name: 'list', tag: 'list', id: 'list', }
  # info ISL.cover ascii, [ 'f', 'F', { lo: '0', hi: '9', }, ], pick: 'id'
  # console.log ISL.find_names_with_all_points ascii, [ 'c'     , ]
  # console.log ISL.find_names_with_all_points ascii, [ 'C'     , ]
  # console.log ISL.find_names_with_all_points ascii, [ 'c', 'C', ]
  # console.log ISL.find_names_with_all_points ascii, [ 'C', 'C', ]
  # console.log ISL.find_names_with_all_points ascii, [ 'C', 'A', ]
  # console.log ISL.find_names_with_all_points ascii, [ 'c', 'A', ]
  # console.log ISL.find_names_with_all_points ascii, [ 'A', 'e', ]
  # console.log ISL.find_names_with_all_points ascii, [ 'i', 'e', ]
  # console.log ISL.find_names_with_all_points ascii, [ '2', 'e', ]
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@dump_api = ( T ) ->
  debug ( Object.keys ISL ).sort()


############################################################################################################
unless module.parent?
  include = [
    # "test interval tree 1"
    # "test interval tree 2"
    # "test interval tree 3"
    # "aggregation 1"
    # "aggregation 2"
    # "characters as points 1"
    # "characters as points 2"
    # "characters as points 3"
    # "intervals_from_points"
    # "new API for points"
    # "readme example 1"
    # "readme example 2"
    # "intervals without ID, name"
    # "preserve insertion order"
    # "demo discontiguous ranges"
    # "unique names with priority conflict"
    # "tag 1"
    # "tag 2"
    # "tag 2a"
    # "tag 2b"
    # "tag 3"
    # "configurable reducers, negative tags"
    # "complements"
    # "infinity is a valid number"
    "(v3) cover, intersect"
    # "dump_api"
  ]
  @_prune()
  @_main()

  # @[ "(v3) cover, intersect" ]()


  # demo_unassigned_unicode_codepoints = ->
  #   console.time 'A'
  #   ucps          = require '../../scratch/interskiplist/lib/unicode-9.0.0-codepoints.js'
  #   cp_intervals  = ISL.intervals_from_points null, ucps.codepoints, ucps.ranges...
  #   console.timeEnd 'A'
  #   console.time 'B'
  #   u             = ISL.new()
  #   ISL.add u, { lo: 0x0, hi: 0x10ffff, tag: 'unassigned', }
  #   for cp_interval in cp_intervals
  #     { lo, hi, } = cp_interval
  #     ISL.add u, { lo, hi, tag: '-unassigned assigned', }
  #   console.timeEnd 'B'
  #   for cid in [ 885 .. 915 ]
  #     chr   = String.fromCodePoint cid
  #     tags  = ( ISL.aggregate u, cid )[ 'tag' ].join ' '
  #     debug ( hex cid ), chr, ( CND.truth cid in ucps.codepoints ), tags
  #   help ISL.aggregate u, 'a'
  # demo_unassigned_unicode_codepoints()

  # isl = ISL.new()
  # ISL.add isl, { lo: 27, hi: 54, }
  # debug isl
  # exclude = ( Object.keys isl[ '%self' ] )
  # exclude.push 'inspect'
  # exclude.push 'toString'
  # help key for key in ( key for key of isl[ '%self' ] when key not in exclude ).sort()



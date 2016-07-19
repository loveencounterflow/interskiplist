


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


###
#-----------------------------------------------------------------------------------------------------------
@_demo = ->
  badge = 'CND/INTERSKIPLIST/demo'
  help  = CND.get_logger 'help',      badge
  urge  = CND.get_logger 'urge',      badge
  SL    = @
  show  = ( node ) ->
    this_key    = node[ 'key' ]
    this_value  = node[ 'value' ]
    this_m      = node[ get_m_sym ]()
    help this_key, this_value, this_m
    show left_node  if (  left_node = node[ 'left'  ] )?
    show right_node if ( right_node = node[ 'right' ] )?
    return null
  skiplist  = SL.new()
  # intervals = [
  #   [ 3, 7, 'A', ]
  #   [ 5, 7, 'B', ]
  #   [ 8, 12, 'C1', ]
  #   [ 8, 12, 'C2', ]
  #   [ 2, 14, 'D', null ]
  #   [ 4, 4, 'E', [ 'helo', ] ]
  #   [ 10, 13, 'F', ]
  #   [ 8, 22, 'G', ]
  #   [ 1, 3, 'H', ]
  #   ]
  intervals = [
    [ 1, 3, 'A', ]
    [ 2, 14, 'B', ]
    [ 3, 7, 'C', ]
    [ 4, 4, 'D', ]
    [ 5, 7, 'E', ]
    [ 8, 12, 'F1', ]
    [ 8, 12, 'F2', ]
    [ 8, 22, 'G', ]
    [ 10, 13, 'H', ]
    ]
  for [ lo, hi, id, value, ] in intervals
    SL.add_interval skiplist, lo, hi, id, value
  for n in [ 0 .. 15 ]
    help n, \
      ( ( SL.find_any_ids skiplist, n ).join ',' ), \
      ( SL.find_any_intervals skiplist, n ), \
      ( SL.find_any_values skiplist, n )
  # show skiplist[ '%self' ][ 'root' ]
  # SL.add_interval skiplist, [ 10, 13, 'FF' ]
  return null
###


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
  throw Error "there were #{error_count} errors" unless error_count is 0
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "Unicode demo" ] = ( T ) ->
  unicode_areas = ISL.new()
  last_cid      = 0x10ffff
  page_idx      = -1
  loop
    page_idx += 1
    page_id   = "page-x#{page_idx.toString 16}"
    lo        = page_idx  * 0x80
    hi        = lo        + 0x7f
    ISL.add_interval unicode_areas, lo, hi, page_id
    break if lo > last_cid
  #.........................................................................................................
  rsg_registry = require '../../../ncr/lib/character-sets-and-ranges'
  for csg, ranges of rsg_registry[ 'names-and-ranges-by-csg' ]
    continue unless csg in [ 'u', 'jzr', ]
    for range in ranges
      name        = range[ 'range-name' ]
      rsg         = range[ 'rsg'        ]
      lo          = range[ 'first-cid'  ]
      hi          = range[ 'last-cid'   ]
      ISL.add_interval unicode_areas, lo, hi, name, { name, lo, hi, rsg, }
  #.........................................................................................................
  # for cid in [ 0x0 .. 0x300 ]
  #   debug ( cid.toString 16 ), find_id_text unicode_areas, cid
  for glyph in Array.from "helo äöü你好𢕒𡕴𡕨𠤇"
    cid     = glyph.codePointAt 0
    cid_hex = hex cid
    # debug glyph, cid_hex, find_id_text unicode_areas, cid
    help glyph, cid_hex, JSON.stringify ISL.find_all_values unicode_areas, cid
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



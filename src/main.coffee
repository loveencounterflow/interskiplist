

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'INTERSKIPLIST'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
σ_plus_א                  = Symbol.for '+א'
σ_minus_א                 = Symbol.for '-א'
σ_misfit                  = Symbol.for 'misfit'
#...........................................................................................................
{ mix, }                  = require 'multimix'


#-----------------------------------------------------------------------------------------------------------
@new = ( settings ) ->
  throw new Error "settings not supported" if settings?
  isl_settings =
    minIndex: σ_minus_א
    maxIndex: σ_plus_א
    compare:  ( a, b ) ->
      return  0 if a is b and ( a is σ_plus_א or a is σ_minus_א )
      return +1 if ( a is σ_plus_א  ) or ( b is σ_minus_א )
      return -1 if ( a is σ_minus_א ) or ( b is σ_plus_א  )
      return +1 if a > b
      return -1 if a < b
      return  0
  #.........................................................................................................
  substrate           = new ( require 'interval-skip-list' ) isl_settings
  substrate.toString  = substrate.inspect = -> "{ interval-skip-list }"
  #.........................................................................................................
  R =
    '~isa':           'CND/interskiplist'
    '%self':          substrate
    'entry-by-ids':   {}
    'idx-by-names':   {}
    'ids-by-names':   {}
    'name-by-ids':    {}
    'idx-by-ids':     {}
    'ids':            []
    'idx':            -1
    'min':            null
    'max':            null
    'fmin':           null
    'fmax':           null
    'indexes':        {}
  #.........................................................................................................
  return R

#-----------------------------------------------------------------------------------------------------------
@copy = ( me ) ->
  R = @new()
  @add_index  R, name                 for name  of me[ 'indexes' ]
  @add        R, CND.deep_copy entry  for entry in @entries_of me
  return R

#-----------------------------------------------------------------------------------------------------------
@add = ( me, entry ) ->
  ### TAINT currently we keep the identity of `entry` and amend it; wouldn't it be better to copy? or deep
  copy? it and then amend it? ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  throw new Error "expected a POD, got a #{CND.type_of entry}" unless CND.isa_pod entry
  { lo, hi, id, name, } = entry
  throw new Error "expected setting for 'lo', found none" unless lo?
  throw new Error "expected setting for 'hi', found none" unless hi?
  lo                          = as_number lo
  hi                          = as_number hi
  name                       ?= '+'
  group_idx                   = ( me[ 'idx-by-names' ][ name ] = ( me[ 'idx-by-names' ][ name ] ? -1 ) + 1 )
  global_idx                  = ( me[ 'idx' ] += +1 )
  id                         ?= "#{name}[#{group_idx}]"
  entry[ 'lo'         ]       = lo
  entry[ 'hi'         ]       = hi
  entry[ 'idx'        ]       = global_idx
  entry[ 'id'         ]       = id
  entry[ 'name'       ]       = name
  entry[ 'size'       ]       = hi - lo + 1
  entry[ 'tag'        ]       = normalize_tag entry[ 'tag' ] if entry[ 'tag' ]?
  me[ 'min'           ]      ?= lo
  me[ 'min'           ]       = Math.min me[ 'min' ], lo
  me[ 'max'           ]      ?= hi
  me[ 'max'           ]       = Math.max me[ 'max' ], lo
  if CND.isa_number lo
    me[ 'fmin'  ]              ?= lo
    me[ 'fmin'  ]               = Math.min me[ 'fmin' ], lo
  if CND.isa_number hi
    me[ 'fmax'  ]              ?= hi
    me[ 'fmax'  ]               = Math.max me[ 'fmax' ], lo
  me[ 'name-by-ids'   ][ id ] = name
  me[ 'idx-by-ids'    ][ id ] = global_idx
  me[ 'entry-by-ids'  ][ id ] = entry ? null
  ( me[ 'ids-by-names' ][ name ] ?= [] ).push id
  me[ '%self' ].insert id, lo, hi
  me[ 'ids' ].push id
  #.........................................................................................................
  @_index_entry me, entry
  #.........................................................................................................
  return id

#-----------------------------------------------------------------------------------------------------------
@delete = ( me, id ) -> me[ '%self' ].remove id


#===========================================================================================================
# SERIALIZATION
#-----------------------------------------------------------------------------------------------------------
@to_xjson = ( me ) ->
  R =
    'index-keys': ( key   for key       of me[ 'indexes'      ] )
    'entries':    ( entry for _, entry  of me[ 'entry-by-ids' ] )
  return CND.XJSON.stringify R, null, '  '

#-----------------------------------------------------------------------------------------------------------
@new_from_xjson = ( xjson ) ->
  description = CND.XJSON.parse xjson
  R           = @new()
  @add_index  R, key    for key   in description[ 'index-keys'  ]
  @add        R, entry  for entry in description[ 'entries'     ]
  return R


#===========================================================================================================
# INDEXING
#-----------------------------------------------------------------------------------------------------------
@add_index = ( me, name ) ->
  throw new Error "index for #{rpr name} already exists" if me[ 'indexes' ][ name ]?
  return me[ 'indexes' ][ name ] = {}

#-----------------------------------------------------------------------------------------------------------
@delete_index = ( me, name, fallback ) ->
  fallback  = σ_misfit if fallback is undefined
  R         = me[ 'indexes' ][ name ] ? fallback
  throw new Error "no index for field #{rpr name}" if R is σ_misfit
  delete me[ 'indexes' ][ name ]
  return R

#-----------------------------------------------------------------------------------------------------------
@find_ids = ( me, name, value ) ->
  throw new Error "no index for field #{rpr name}" unless ( index = me[ 'indexes' ][ name ] )?
  return [] unless ( R = index[ value ] )?
  return Object.assign [], R

#-----------------------------------------------------------------------------------------------------------
@find_entries = ( me, name, value ) ->
  R         = @find_ids me, name, value
  R[ idx ]  = me[ 'entry-by-ids' ][ id ] for id, idx in R
  return R

#-----------------------------------------------------------------------------------------------------------
@_index_entry = ( me, entry ) ->
  { id, } = entry
  #.........................................................................................................
  if ( indexes = me[ 'indexes' ] )?
    for name, value of entry
      continue unless ( index = indexes[ name ] )
      ### TAINT this is a minimally viable product; indexing behavior should be configurable ###
      if name is 'tag'
        for tag in normalize_tag value
          ( index[ tag ] ?= [] ).push id
      else
        ( index[ value ] ?= [] ).push id
  #.........................................................................................................
  return null

#===========================================================================================================
# COVER AND INTERSECT
#-----------------------------------------------------------------------------------------------------------
@match      = ( me, points, settings = {} ) -> @_cover_or_intersect me, 'match',      points, settings
@intersect  = ( me, points, settings = {} ) -> @_cover_or_intersect me, 'intersect',  points, settings

#-----------------------------------------------------------------------------------------------------------
@_cover_or_intersect = ( me, mode, points, settings ) ->
  ### TAINT can probably be greatly simplified since advanced functionality here is not needed ###
  unless CND.is_subset ( keys = Object.keys settings ), setting_keys_of_cover_and_intersect
    expected  = setting_keys_of_cover_and_intersect.join ', '
    got       = keys.join ', '
    throw new Error "expected settings out of #{expected}, got #{got}"
  { pick, }   = settings
  if mode is 'match' then R = @_find_ids_with_all_points me, points
  else                    R = @_find_ids_with_any_points me, points
  return R if pick is 'id'
  R = @entries_of me, R
  if pick?
    R = ( entry[ pick ] for entry in R )
    return reduce_tag R if pick is 'tag'
  return fuse R

#-----------------------------------------------------------------------------------------------------------
setting_keys_of_cover_and_intersect = [ 'pick', ]


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
@entries_of = ( me, ids = null ) ->
  unless ids?
    R = ( entry for _, entry of me[ 'entry-by-ids' ] )
  else
    R = []
    for id in ids
      throw new Error "unknown ID #{rpr id}" unless ( entry = me[ 'entry-by-ids' ][ id ] )?
      R.push entry
  return sort_entries_by_insertion_order me, R

#-----------------------------------------------------------------------------------------------------------
@_find_ids_with_any_points = ( me, points ) ->
  points = normalize_points points
  return me[ '%self' ].findContaining points... if points.length < 2
  R = new Set()
  for point in points
    ids = me[ '%self' ].findContaining point
    R.add id for id in ids
  return sort_ids_by_insertion_order me, Array.from R

#-----------------------------------------------------------------------------------------------------------
@_find_ids_with_all_points = ( me, points ) ->
  points = normalize_points points
  return me[ '%self' ].findContaining points...

#-----------------------------------------------------------------------------------------------------------
@intervals_from_points = ( me, points, mixins... ) ->
  mixin = ( lohi ) ->
    return lohi unless mixins.length > 0
    return Object.assign {}, mixins..., lohi
  points = [ points, ] unless CND.isa_list points
  points = unique as_numbers points
  points.sort ( a, b ) ->
    return +1 if a > b
    return -1 if a < b
    return  0
  R           = []
  last_point  = null
  last_lo     = null
  last_hi     = null
  for point in points
    unless last_lo?
      last_lo     = point
      last_hi     = point
      last_point  = point
      continue
    if point is last_point + 1
      last_hi     = point
      last_point  = point
      continue
    R.push ( mixin { lo: last_lo, hi: last_hi, } )
    last_lo     = point
    last_hi     = point
    last_point  = point
  R.push ( mixin { lo: last_lo, hi: last_hi, } ) if last_lo? and last_hi?
  return R


#===========================================================================================================
# AGGREGATION
#-----------------------------------------------------------------------------------------------------------
@aggregate = ( me, point, reducers = null ) -> ( @aggregate.use me, reducers ) point

#-----------------------------------------------------------------------------------------------------------
@aggregate.use = ( me, reducers ) =>
  #.........................................................................................................
  if ( not reducers? ) or ( Object.keys reducers ).length is 0
    mix = @aggregate._mix
  else
    mixins    = [ {}, ]
    mixins.push @aggregate._reducers
    mixins.push reducers if reducers?
    reducers  = Object.assign mixins...
    mix       = mix.use reducers
  #.........................................................................................................
  return ( point ) =>
    point_count = if ( CND.isa_list point ) then point.length else 1
    throw new Error "need single point, got #{point_count}" unless point_count is 1
    entries     = @entries_of me, @_find_ids_with_any_points me, point
    return mix entries...

#-----------------------------------------------------------------------------------------------------------
@aggregate._reducers =
    idx:    'skip'
    id:     'skip'
    name:   'skip'
    lo:     'skip'
    hi:     'skip'
    size:   'skip'
    tag:    'tag'

#-----------------------------------------------------------------------------------------------------------
@aggregate._mix = mix.use @aggregate._reducers


#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
sort_entries_by_insertion_order = ( me, entries ) ->
  entries.sort ( a, b ) ->
    return +1 if a[ 'idx' ] > b[ 'idx' ]
    return -1 if a[ 'idx' ] < b[ 'idx' ]
    return  0
  return entries

#-----------------------------------------------------------------------------------------------------------
sort_ids_by_insertion_order = ( me, ids ) ->
  idxs = me[ 'idx-by-ids' ]
  ids.sort ( a, b ) ->
    return +1 if idxs[ a ] > idxs[ b ]
    return -1 if idxs[ a ] < idxs[ b ]
    return  0
  return ids

#-----------------------------------------------------------------------------------------------------------
as_number = ( x ) ->
  return x if x in [ -Infinity, +Infinity, ] or CND.isa_number x
  unless ( type = CND.type_of x ) is 'text'
    throw new Error "expected number or single character text, got a #{type}"
  unless ( length = ( Array.from x ).length ) is 1
    throw new Error "expected single character text, got one of length #{length}"
  return x.codePointAt 0

#-----------------------------------------------------------------------------------------------------------
as_numbers = ( list ) -> ( as_number x for x in list )

#-----------------------------------------------------------------------------------------------------------
normalize_points = ( points ) ->
  points = [ points, ] unless CND.isa_list points
  return as_numbers points

#-----------------------------------------------------------------------------------------------------------
normalize_tag = ( tag ) ->
  ### Given a single string or a list of strings, return a new list that contains all whitespace-delimited
  words in the strings ###
  return normalize_tag [ tag, ] unless CND.isa_list tag
  R = []
  for t in tag
    continue if t.length is 0
    R.splice R.length, 0, ( t.split /\s+/ )...
  ### TAINT consider to return `unique R` instead ###
  return R

#-----------------------------------------------------------------------------------------------------------
unique = ( list ) ->
  ### Return a copy of `list´ that only contains the last occurrence of each value ###
  ### TAINT consider to modify, not copy `list` ###
  seen  = new Set()
  R     = []
  for idx in [ list.length - 1 .. 0 ] by -1
    element = list[ idx ]
    continue if seen.has element
    seen.add element
    R.unshift element
  return R

#-----------------------------------------------------------------------------------------------------------
append = ( a, b ) ->
  ### Append elements of list `b` to list `a` ###
  ### TAINT JS has `[]::concat` ###
  a.splice a.length, 0, b...
  return a

#-----------------------------------------------------------------------------------------------------------
meld = ( list, value ) ->
  ### When `value` is a list, `append` it to `list`; else, `push` `value` to `list` ###
  if CND.isa_list value then  append list, value
  else                        list.push value
  return list

#-----------------------------------------------------------------------------------------------------------
fuse = ( list ) ->
  ### Flatten `list`, then apply `unique` to it. Does not copy `list` but modifies it ###
  R = []
  meld R, element for element in list
  R = unique R
  list.splice 0, list.length, R...
  return list

#-----------------------------------------------------------------------------------------------------------
reduce_tag = ( raw ) ->
  source  = fuse raw
  R       = []
  exclude = null
  #.........................................................................................................
  for idx in [ source.length - 1 .. 0 ] by -1
    tag = source[ idx ]
    continue if exclude? and exclude.has tag
    if tag.startsWith '-'
      break if tag is '-*'
      ( exclude ?= new Set() ).add tag[ 1 .. ]
      continue
    R.unshift tag
  #.........................................................................................................
  return R





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


#-----------------------------------------------------------------------------------------------------------
@new = ( settings ) ->
  throw new Error "settings not yet supported" if settings?
  substrate = new ( require 'interval-skip-list' )()
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
    'reducers':       settings[ 'reducers' ] ? null
  return R

#-----------------------------------------------------------------------------------------------------------
@insert = ( me, entry ) ->
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
  entry[ 'lo'    ]            = lo
  entry[ 'hi'    ]            = hi
  entry[ 'idx'   ]            = global_idx
  entry[ 'id'    ]            = id
  entry[ 'name'  ]            = name
  entry[ 'size'  ]            = hi - lo + 1
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
  return id

#-----------------------------------------------------------------------------------------------------------
@remove = ( me, id ) -> me[ '%self' ].remove id

#-----------------------------------------------------------------------------------------------------------
@interval_of = ( me, id ) ->
  throw new Error "unknown ID #{rpr id}" unless ( R = me[ '%self' ].intervalsByMarker[ id ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@entry_of = ( me, id ) ->
  throw new Error "unknown ID #{rpr id}" unless ( R = me[ 'entry-by-ids' ][ id ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@name_of = ( me, id ) ->
  throw new Error "unknown ID #{rpr id}" unless ( R = me[ 'name-by-ids' ][ id ] )?
  return R

#-----------------------------------------------------------------------------------------------------------
@tag_of = ( me, id ) ->
  ### NOTE always returns a (possibly empty) list; always returns a copy, never the original list ###
  throw new Error "unknown ID #{rpr id}" unless ( entry = me[ 'entry-by-ids' ][ id ] )?
  R = entry[ 'tag' ]
  return [] unless R?
  return meld [], R

#-----------------------------------------------------------------------------------------------------------
@_intervals_of = ( me, ids = null ) ->
  return me[ '%self' ].intervalsByMarker unless ids?
  return ( @interval_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@_entries_of = ( me, ids = null ) ->
  return ( entry for _, entry of me[ 'entry-by-ids' ] ) unless ids?
  return ( @entry_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@_names_of = ( me, ids = null ) ->
  return me[ 'name-by-ids' ] unless ids?
  return unique ( @name_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@_tags_of = ( me, ids = null ) ->
  throw new Error "retrieving tags without IDs not implemented" unless ids?
  return fuse ( @tag_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@intervals_of = ( me, ids = null ) -> @_intervals_of me, if ids? then ( @sort_ids me, ids ) else null
@entries_of   = ( me, ids = null ) -> @_entries_of   me, if ids? then ( @sort_ids me, ids ) else null
@names_of     = ( me, ids = null ) -> @_names_of     me, if ids? then ( @sort_ids me, ids ) else null
@tags_of      = ( me, ids = null ) -> @_tags_of      me, if ids? then ( @sort_ids me, ids ) else null

#-----------------------------------------------------------------------------------------------------------
@find_ids       = ( me, point ) -> @find_ids_with_all_points        me, point
@find_intervals = ( me, point ) -> @find_intervals_with_all_points  me, point
@find_entries   = ( me, point ) -> @find_entries_with_all_points    me, point
@find_names     = ( me, point ) -> @find_names_with_all_points      me, point
@find_tags      = ( me, point ) -> @find_tags_with_all_points       me, point

#-----------------------------------------------------------------------------------------------------------
### TAINT what happens when these methods are called with no points? ###
@find_entries_with_any_points   = ( me, P... ) -> @entries_of   me, @find_ids_with_any_points me, P...
@find_names_with_any_points     = ( me, P... ) -> @names_of     me, @find_ids_with_any_points me, P...
@find_intervals_with_any_points = ( me, P... ) -> @intervals_of me, @find_ids_with_any_points me, P...
@find_tags_with_any_points      = ( me, P... ) -> @tags_of      me, @find_ids_with_any_points me, P...

#-----------------------------------------------------------------------------------------------------------
@find_entries_with_all_points   = ( me, P... ) -> @entries_of   me, @find_ids_with_all_points me, P...
@find_intervals_with_all_points = ( me, P... ) -> @intervals_of me, @find_ids_with_all_points me, P...

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_any_points = ( me, points ) ->
  ### TAINT should be possible to call w/o any points to get all IDs ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  ### Note: `Intervalskiplist::findIntersecting` needs more than a single probe, so we fall back to
  `::findContaining` in case a single probe was given. ###
  return @find_ids_with_all_points me, points if points.length < 2
  points = as_numbers points
  ### TAINT findIntersecting appears to be not working as advertised; workaraound: ###
  # return me[ '%self' ].findIntersecting points...
  R = new Set()
  for point in points
    ids = me[ '%self' ].findContaining point
    R.add id for id in ids
  return @sort_ids me, Array.from R

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_all_points = ( me, points ) ->
  ### TAINT should be possible to call w/o any points to get no IDs ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  points = as_numbers points
  return me[ '%self' ].findContaining points...

#-----------------------------------------------------------------------------------------------------------
@find_names_with_all_points = ( me, points ) ->
  ### TAINT code duplication ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  return [] if points.length is 0
  R = @find_names_with_any_points me, points[ 0 ]
  return R if points.length < 2
  R = new Set R
  for point_idx in [ 1 ... points.length ]
    point = points[ point_idx ]
    names = @find_names_with_any_points me, point
    R.forEach ( name ) -> R.delete name unless name in names
  return Array.from R

#-----------------------------------------------------------------------------------------------------------
@find_tags_with_all_points = ( me, points ) ->
  ### TAINT code duplication ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  return [] if points.length is 0
  R = @find_tags_with_any_points me, points[ 0 ]
  return R if points.length < 2
  R = new Set R
  for point_idx in [ 1 ... points.length ]
    point = points[ point_idx ]
    tags  = @find_tags_with_any_points me, point
    R.forEach ( tag ) -> R.delete tag unless tag in tags
  return Array.from R

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
@sort_entries = ( me, entries ) ->
  entries.sort ( a, b ) ->
    return +1 if a[ 'idx' ] > b[ 'idx' ]
    return -1 if a[ 'idx' ] < b[ 'idx' ]
    return  0
  return entries

#-----------------------------------------------------------------------------------------------------------
@sort_ids = ( me, ids ) ->
  idxs = me[ 'idx-by-ids' ]
  ids.sort ( a, b ) ->
    return +1 if idxs[ a ] > idxs[ b ]
    return -1 if idxs[ a ] < idxs[ b ]
    return  0
  return ids

#-----------------------------------------------------------------------------------------------------------
@aggregate = ( me, points_or_entries, reducers = {} ) ->
  if reducers? and not CND.isa_pod reducers
    throw new Error "expected a POD for reducer, got a #{CND.type_of reducers}"
  ### Separate points from entries, splice them together with those points found for the points, and sort
  the result: ###
  points_or_entries = [ points_or_entries, ] unless CND.isa_list points_or_entries
  points            = []
  entries           = []
  for points_or_entry in points_or_entries
    if ( CND.type_of points_or_entry ) in [ 'number', 'text', ]
      points.push points_or_entry
    else
      entries.push points_or_entry
  if points.length > 0
    entries.splice 0, 0, ( @find_entries_with_all_points me, points )...
  @sort_entries me, entries
  #.........................................................................................................
  R                 = {}
  cache             = {}
  averages          = {}
  common            = {}
  tag_keys          = ( key for key, value of reducers when value is 'tag' )
  exclude           = ( key for key in [ 'idx', 'id', 'lo', 'hi', 'size', ] when not ( key of reducers ) )
  reducer_fallback  = reducers[ '*' ] ? 'assign'
  #.........................................................................................................
  unless ( 'tag' in exclude ) or ( 'tag' of reducers )
    tag_keys.push 'tag'
    reducers[ 'tag' ] = 'tag'
  #.........................................................................................................
  for entry in entries
    for key, value of entry
      continue if key in exclude
      reducer = ( reducer = reducers[ key ] ) ? reducer_fallback
      reducer = reducer_fallback if reducer is 'include'
      #.....................................................................................................
      switch reducer
        when 'skip'     then continue
        when 'list'     then ( R[ key ]      ?= [] ).push value
        when 'add'      then R[ key ]         = ( R[ key ] ? 0 ) + value
        when 'assign'   then R[ key ]         = value
        when 'tag'      then meld ( target = R[ key ] ?= [] ), value
        #...................................................................................................
        when 'average'
          target      = averages[ key ] ?= [ 0, 0, ]
          target[ 0 ] = target[ 0 ] + value
          target[ 1 ] = target[ 1 ] + 1
        #...................................................................................................
        else
          ### TAINT repeats typecheck on each iteration ###
          throw new Error "unknwon reducer #{rpr reducer}" unless CND.isa_function reducer
          ( cache[ key ] ?= [] ).push [ entry[ 'id' ], value, ]
  #.........................................................................................................
  for key, value of R
    continue unless key in tag_keys
    R[ key ] = fuse value
  #.........................................................................................................
  for key, [ sum, count, ] of averages
    R[ key ] = sum / count
  #.........................................................................................................
  for key, values of common
    R[ key ] = values[ 0 ] if ( values.length is 1 ) or CND.equals values...
  #.........................................................................................................
  for key, ids_and_values of cache
    R[ key ] = reducers[ key ] ids_and_values, R, entries
  #.........................................................................................................
  return R


#===========================================================================================================
# HELPERS
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
unique = ( list ) ->
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
  a.splice a.length, 0, b...
  return a

#-----------------------------------------------------------------------------------------------------------
meld = ( list, value ) ->
  if CND.isa_list value then  append list, value
  else                        list.push value
  return list

#-----------------------------------------------------------------------------------------------------------
fuse = ( list ) ->
  R = []
  meld R, element for element in list
  R = unique R
  list.splice 0, list.length, R...
  return list





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
    'idx':            -1
    'min':            null
    'max':            null
    'fmin':           null
    'fmax':           null
  return R

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
@insert = ( me, entry ) ->
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  throw new Error "expected a POD, got a #{CND.type_of entry}" unless CND.isa_pod entry
  { lo, hi, id, name, } = entry
  throw new Error "expected setting for 'lo', found none" unless lo?
  throw new Error "expected setting for 'hi', found none" unless hi?
  throw new Error "expected at least one setting for 'name' or 'id', found none" unless name? or id?
  lo                          = as_number lo
  hi                          = as_number hi
  name                       ?= '*'
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
  me[ 'entry-by-ids'  ][ id ] = entry ? null
  ( me[ 'ids-by-names' ][ name ] ?= [] ).push id
  me[ '%self' ].insert id, lo, hi
  return id

#-----------------------------------------------------------------------------------------------------------
@remove = ( me, id ) -> me[ '%self' ].remove id

#-----------------------------------------------------------------------------------------------------------
@interval_of  = ( me, id ) -> me[ '%self' ].intervalsByMarker[ id ]
@entry_of     = ( me, id ) -> me[ 'entry-by-ids'            ][ id ]
@name_of      = ( me, id ) -> me[ 'name-by-ids'             ][ id ]

#-----------------------------------------------------------------------------------------------------------
@intervals_of = ( me, ids = null ) ->
  return me[ '%self' ].intervalsByMarker unless ids?
  return ( @interval_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@entries_of = ( me, ids = null ) ->
  return ( entry for _, entry of me[ 'entry-by-ids' ] ) unless ids?
  return ( @entry_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@names_of = ( me, ids = null ) ->
  return me[ 'name-by-ids' ] unless ids?
  return unique ( @name_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_any_points = ( me, points ) ->
  ### TAINT should be possible to call w/o any points to get all IDs ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  ### Note: `Intervalskiplist::findIntersecting` needs more than a single probe, so we fall back to
  `::findContaining` in case a single probe was given. ###
  return @find_ids_with_all_points me, points if points.length < 2
  points = as_numbers points
  return me[ '%self' ].findIntersecting points...

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_all_points = ( me, points ) ->
  ### TAINT should be possible to call w/o any points to get no IDs ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  points = as_numbers points
  return me[ '%self' ].findContaining points...

#-----------------------------------------------------------------------------------------------------------
### TAINT what happens when these methods are called with no points? ###
@find_entries_with_any_points = ( me, P... ) -> @entries_of me, @find_ids_with_any_points me, P...
@find_entries_with_all_points = ( me, P... ) -> @entries_of me, @find_ids_with_all_points me, P...
@find_names_with_any_points   = ( me, P... ) -> @names_of   me, @find_ids_with_any_points me, P...

#-----------------------------------------------------------------------------------------------------------
@find_names_with_all_points = ( me, points ) ->
  ### TAINT should be possible to call w/o any points to get no names ###
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  points = [ points, ] unless CND.isa_list points
  return [] if points.length is 0
  R = @find_names_with_any_points me, points[ 0 ]
  # debug '1101-1', points[ 0 ], @find_ids_with_any_points me, points[ 0 ]
  # debug '1101-1', points[ 0 ], @find_names_with_any_points me, points[ 0 ]
  # debug '1101-1', points[ 0 ], me[ 'name-by-ids' ]
  return R if points.length < 2
  R = new Set R
  # debug '1101-2', R
  for point_idx in [ 1 ... points.length ]
    point = points[ point_idx ]
    names = @find_names_with_any_points me, point
    # help '3200', R, names
    R.forEach ( name ) -> R.delete name unless name in names
    # warn '3200', R, names
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

#-----------------------------------------------------------------------------------------------------------
unique = ( list ) ->
  seen  = new Set()
  R     = []
  for element in list
    continue if seen.has element
    seen.add element
    R.push element
  return R


#===========================================================================================================
# AGGREGATION
#-----------------------------------------------------------------------------------------------------------
@sort_entries = ( me, entries ) ->
  entries.sort ( a, b ) ->
    [ a_size, b_size, ] = [ a[ 'size' ], b[ 'size' ], ]
    return -1 if a_size > b_size
    return +1 if a_size < b_size
    [ a_idx, b_idx, ] = [ a[ 'idx' ], b[ 'idx' ], ]
    return +1 if a_idx > b_idx
    return -1 if a_idx < b_idx
    return  0
  return entries

#-----------------------------------------------------------------------------------------------------------
@aggregate = ( me, points, reducers = {} ) ->
  if reducers? and not CND.isa_pod reducers
    throw new Error "expected a POD for reducer, got a #{CND.type_of reducers}"
  entries = @find_entries_with_all_points me, points
  @sort_entries me, entries
  R         = {}
  cache     = {}
  averages  = {}
  for entry in entries
    for key, value of entry
      continue if key in [ 'idx', 'id', 'name', 'lo', 'hi', 'size', ]
      switch ( reducer = reducers[ key ] ) ? 'assign'
        when 'skip'     then continue
        when 'list'     then ( R[ key ]      ?= [] ).push value
        when 'add'      then R[ key ]         = ( R[ key ] ? 0 ) + value
        when 'assign'   then R[ key ]         = value
        when 'average'  then averages[ key ]  = ( averages[ key ] ? 0 ) + value
        else
          throw new Error "unknwon reducer #{rpr reducer}" unless CND.isa_function reducer
          ( cache[ key ] ?= [] ).push [ entry[ 'id' ], value, ]
  for key, facets of cache
    R[ key ] = reducers[ key ] facets, R, entries
  return R





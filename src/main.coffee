
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
  return R

#-----------------------------------------------------------------------------------------------------------
as_number = ( x ) ->
  return x if x in [ -Infinity, +Infinity, ] or CND.isa_number x
  unless ( CND.type_of x ) is 'text'
    throw new Error "expected number or single character text, got a #{type}"
  unless ( length = ( Array.from x ).length ) is 1
    throw new Error "expected single character text, got one of length #{length}"
  return x.codePointAt 0

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
  entry[ 'size'  ]            = hi - lo + 1
  entry[ 'id'    ]            = id
  entry[ 'idx'   ]            = global_idx
  entry[ 'name'  ]            = name
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
  return me[ 'entry-by-ids' ] unless ids?
  return ( @entry_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@names_of = ( me, ids = null ) ->
  return me[ 'name-by-ids' ] unless ids?
  return unique ( @name_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_any_points = ( me, points... ) ->
  ### Note: `Intervalskiplist::findIntersecting` needs more than a single probe, so we fall back to
  `::findContaining` in case a single probe was given. ###
  return @find_ids_with_any_points me, points[ 0 ]... if CND.isa_list points[ 0 ]
  return @find_ids_with_all_points me, points... if points.length < 2
  return me[ '%self' ].findIntersecting points...

#-----------------------------------------------------------------------------------------------------------
@find_ids_with_all_points = ( me, points... ) ->
  return @find_ids_with_all_points me, points[ 0 ]... if CND.isa_list points[ 0 ]
  return me[ '%self' ].findContaining points...

#-----------------------------------------------------------------------------------------------------------
@find_entries_with_any_points  = ( me, points... ) -> @entries_of me, @find_ids_with_any_points me, points...
@find_entries_with_all_points  = ( me, points... ) -> @entries_of me, @find_ids_with_all_points me, points...
@find_names_with_any_points   = ( me, points... ) -> @names_of me, @find_ids_with_any_points me, points...
@find_names_with_all_points   = ( me, points... ) -> @names_of me, @find_ids_with_all_points me, points...

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
@aggregate = ( me, points..., reducers ) ->
  unless CND.isa_pod reducers
    points.push reducers
    reducers = {}
  entries = @find_entries_with_all_points me, points...
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





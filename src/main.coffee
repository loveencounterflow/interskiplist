
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
    'value-by-ids':   {}
    'count-by-names': {}
    'ids-by-names':   {}
    'name-by-ids':    {}
  return R

#-----------------------------------------------------------------------------------------------------------
@insert = ( me, settings ) ->
  throw new Error "expected 2 arguments, got #{arity}" unless ( arity = arguments.length ) is 2
  throw new Error "expected a POD, got a #{CND.type_of settings}" unless CND.isa_pod settings
  { lo, hi, id, name, } = settings
  throw new Error "expected setting for 'lo', found none" unless lo?
  throw new Error "expected setting for 'hi', found none" unless hi?
  throw new Error "expected at least one setting for 'name' or 'id', found none" unless name? or id?
  name ?= '*'
  idx   = ( me[ 'count-by-names' ][ name ] = ( me[ 'count-by-names' ][ name ] ? 0 ) + 1 ) - 1
  id   ?= "#{name}[#{idx}]"
  settings[ 'id'    ]       = id
  settings[ 'name'  ]       = name
  me[ 'name-by-ids' ][ id ] = name
  ( me[ 'ids-by-names' ][ name ] ?= [] ).push id
  return @_insert me, lo, hi, id, settings

#-----------------------------------------------------------------------------------------------------------
@_insert = ( me, lo, hi, id, value ) ->
  throw new Error "need an ID" unless id?
  value = id if value is undefined
  me[ '%self' ].insert id, lo, hi
  me[ 'value-by-ids' ][ id ] = value ? null
  return id

#-----------------------------------------------------------------------------------------------------------
@remove = ( me, id ) -> me[ '%self' ].remove id

#-----------------------------------------------------------------------------------------------------------
@interval_of  = ( me, id ) -> me[ '%self' ].intervalsByMarker[ id ]
@value_of     = ( me, id ) -> me[ 'value-by-ids'            ][ id ]
@name_of      = ( me, id ) -> me[ 'name-by-ids'             ][ id ]

#-----------------------------------------------------------------------------------------------------------
@intervals_of = ( me, ids = null ) ->
  return me[ '%self' ].intervalsByMarker unless ids?
  return ( @interval_of me, id for id in ids )

#-----------------------------------------------------------------------------------------------------------
@values_of = ( me, ids = null ) ->
  return me[ 'value-by-ids' ] unless ids?
  return ( @value_of me, id for id in ids )

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
@find_values_with_any_points  = ( me, points... ) -> @values_of me, @find_ids_with_any_points me, points...
@find_values_with_all_points  = ( me, points... ) -> @values_of me, @find_ids_with_all_points me, points...
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






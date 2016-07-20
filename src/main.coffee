
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
@add_interval = ( me, settings ) ->
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
  return @_add_interval me, lo, hi, id, settings

#-----------------------------------------------------------------------------------------------------------
@_add_interval = ( me, lo, hi, id, value ) ->
  throw new Error "need an ID" unless id?
  value = id if value is undefined
  me[ '%self' ].insert id, lo, hi
  me[ 'value-by-ids' ][ id ] = value ? null
  return id

#-----------------------------------------------------------------------------------------------------------
@get_intervals  = ( me     ) -> me[ '%self' ].intervalsByMarker
@get_interval   = ( me, id ) -> ( @get_intervals me )[ id ]
@get_values     = ( me     ) -> me[ 'value-by-ids' ]
@get_value      = ( me, id ) -> ( @get_values me )[ id ]
@get_names      = ( me     ) -> me[ 'name-by-ids' ]
@get_name       = ( me, id ) -> ( @get_names me )[ id ]

#-----------------------------------------------------------------------------------------------------------
@find_any_ids = ( me, probes... ) ->
  ### Note: `Intervalskiplist::findIntersecting` needs more than a single probe, so we fall back to
  `::findContaining` in case a single probe was given. ###
  return @find_all_ids me, probes... if probes.length < 2
  return me[ '%self' ].findIntersecting probes...

#-----------------------------------------------------------------------------------------------------------
@find_all_ids = ( me, probes... ) ->
  return me[ '%self' ].findContaining probes...

#-----------------------------------------------------------------------------------------------------------
@find_any_intervals = ( me, probes... ) ->
  return ( ( @get_interval me, id ) for id in @find_any_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_all_intervals = ( me, probes... ) ->
  return ( ( @get_interval me, id ) for id in @find_all_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_any_values = ( me, probes... ) ->
  return ( ( @get_value me, id ) for id in @find_any_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_all_values = ( me, probes... ) ->
  return ( ( @get_value me, id ) for id in @find_all_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_all_names = ( me, probes... ) ->
  return ( ( @get_name me, id ) for id in @find_all_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_any_names = ( me, probes... ) ->
  return unique ( ( @get_name me, id ) for id in @find_any_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
@find_all_names = ( me, probes... ) ->
  return unique ( ( @get_name me, id ) for id in @find_all_ids me, probes )

#-----------------------------------------------------------------------------------------------------------
unique = ( list ) ->
  seen  = new Set()
  R     = []
  for element in list
    continue if seen.has element
    seen.add element
    R.push element
  return R






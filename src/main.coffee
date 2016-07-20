
############################################################################################################
CND                       = require 'cnd'
# rpr                       = CND.rpr
# urge                      = CND.get_logger 'urge',      badge
# echo                      = CND.echo.bind CND


#-----------------------------------------------------------------------------------------------------------
@new = ( settings ) ->
  throw new Error "settings not yet supported" if settings?
  substrate = new ( require 'interval-skip-list' )()
  R =
    '~isa':         'CND/interskiplist'
    '%self':        substrate
    'value-by-ids': {}
  return R

#-----------------------------------------------------------------------------------------------------------
@add_interval = ( me, lo, hi, id, value ) ->
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



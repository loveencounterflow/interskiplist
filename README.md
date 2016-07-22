



# IntervalSkipList

Binary Search for Numeric & Character Intervals; great for CSS-Unicode-Range-like tasks.

[![npm version](https://badge.fury.io/js/interskiplist.svg)](https://www.npmjs.com/package/interskiplist)
[![Build Status](https://travis-ci.org/loveencounterflow/interskiplist.svg?branch=master)](https://travis-ci.org/loveencounterflow/interskiplist)
![stability-almost stable](https://img.shields.io/badge/stability-almost%20stable-orange.svg)
![slogan-Binary Search FTW](https://img.shields.io/badge/slogan-Binary%20Search%20FTW-blue.svg)

Install as `npm install --save interskiplist`.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [IntervalSkipList](#intervalskiplist)
- [API](#api)
  - [@aggregate = ( me, points, reducers ) ->](#@aggregate---me-points-reducers---)
  - [@entries_of = ( me, ids = null ) ->](#@entries_of---me-ids--null---)
  - [@entry_of     = ( me, id ) ->](#@entry_of-------me-id---)
  - [@find_entries_with_all_points = ( me, P... ) ->](#@find_entries_with_all_points---me-p---)
  - [@find_entries_with_any_points = ( me, P... ) ->](#@find_entries_with_any_points---me-p---)
  - [@find_ids_with_all_points = ( me, points ) ->](#@find_ids_with_all_points---me-points---)
  - [@find_ids_with_any_points = ( me, points ) ->](#@find_ids_with_any_points---me-points---)
  - [@find_names_with_all_points = ( me, points ) ->](#@find_names_with_all_points---me-points---)
  - [@find_names_with_any_points   = ( me, P... ) ->](#@find_names_with_any_points-----me-p---)
  - [@insert = ( me, entry ) ->](#@insert---me-entry---)
  - [@interval_of  = ( me, id ) ->](#@interval_of----me-id---)
  - [@intervals_from_points = ( me, points, mixins... ) ->](#@intervals_from_points---me-points-mixins---)
  - [@intervals_of = ( me, ids = null ) ->](#@intervals_of---me-ids--null---)
  - [@name_of      = ( me, id ) ->](#@name_of--------me-id---)
  - [@names_of = ( me, ids = null ) ->](#@names_of---me-ids--null---)
  - [@new = ( settings ) ->](#@new---settings---)
  - [@remove = ( me, id ) ->](#@remove---me-id---)
  - [@sort_entries = ( me, entries ) ->](#@sort_entries---me-entries---)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Caveat** Below examples are all written in CoffeeScript.

# IntervalSkipList

# Example 1

```coffee
#...........................................................................................................
isl = ISL.new()
ISL.insert isl, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
ISL.insert isl, { lo: 'a', hi: 'z', name: 'letter', }
ISL.insert isl, { lo: 'A', hi: 'Z', name: 'letter', }
ISL.insert isl, { lo: 'a', hi: 'z', name: 'lower', }
ISL.insert isl, { lo: 'A', hi: 'Z', name: 'upper', }
#...........................................................................................................
for chr in 'aeiouAEIOU'
  ISL.insert isl, { lo: chr, hi: chr, name: 'vowel', }
#...........................................................................................................
consonants = Array.from 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
for interval in ISL.intervals_from_points isl, consonants, { name: 'consonant', }
  ISL.insert isl, interval
#...........................................................................................................
digits = Array.from '0123456789'
for interval in ISL.intervals_from_points isl, digits, { name: 'digit', }
  ISL.insert isl, interval
```

```
                ...        0         0         0         0         0         1         1         1         1
                ...        5         6         7         8         9         0         1         2         3
                ...  456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
basic-latin[0]  ...  -----------------------------------------------------------------------------------]
letter[s]       ...                       [------------------------]      [------------------------]
lower           ...                                                       [------------------------]
upper           ...                       [------------------------]
vowels          ...                       H   H   H     H     H           H   H   H     H     H
consonants      ...                        [-] [-] [---] [---] [---]       [-] [-] [---] [---] [---]
digits          ...      [--------]
```
```
ISL.find_names_with_all_points isl, [ 'c'     , ] ---> [ 'basic-latin', 'letter', 'lower', 'consonant' ]
ISL.find_names_with_all_points isl, [ 'C'     , ] ---> [ 'basic-latin', 'letter', 'upper', 'consonant' ]
ISL.find_names_with_all_points isl, [ 'c', 'C', ] ---> [ 'basic-latin', 'letter', 'consonant' ]
ISL.find_names_with_all_points isl, [ 'C', 'C', ] ---> [ 'basic-latin', 'letter', 'upper', 'consonant' ]
ISL.find_names_with_all_points isl, [ 'C', 'A', ] ---> [ 'basic-latin', 'letter', 'upper' ]
ISL.find_names_with_all_points isl, [ 'c', 'A', ] ---> [ 'basic-latin', 'letter' ]
ISL.find_names_with_all_points isl, [ 'A', 'e', ] ---> [ 'basic-latin', 'letter', 'vowel' ]
ISL.find_names_with_all_points isl, [ 'i', 'e', ] ---> [ 'basic-latin', 'letter', 'lower', 'vowel' ]
ISL.find_names_with_all_points isl, [ '2', 'e', ] ---> [ 'basic-latin' ]
```

# API

## @aggregate = ( me, points, reducers ) ->
## @entries_of = ( me, ids = null ) ->
## @entry_of     = ( me, id ) ->
## @find_entries_with_all_points = ( me, P... ) ->
## @find_entries_with_any_points = ( me, P... ) ->
## @find_ids_with_all_points = ( me, points ) ->
## @find_ids_with_any_points = ( me, points ) ->
## @find_names_with_all_points = ( me, points ) ->
## @find_names_with_any_points   = ( me, P... ) ->
## @insert = ( me, entry ) ->
## @interval_of  = ( me, id ) ->
## @intervals_from_points = ( me, points, mixins... ) ->
## @intervals_of = ( me, ids = null ) ->
## @name_of      = ( me, id ) ->
## @names_of = ( me, ids = null ) ->
## @new = ( settings ) ->
## @remove = ( me, id ) ->
## @sort_entries = ( me, entries ) ->





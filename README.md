



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

- [InterSkipList](#interskiplist)
  - [Intro](#intro)
    - [Background](#background)
  - [Intended Usage and Audience](#intended-usage-and-audience)
    - [An Example Using CSS Unicode-Range](#an-example-using-css-unicode-range)
    - [Same Example Using InterSkipList](#same-example-using-interskiplist)
- [Example 1](#example-1)
- [API](#api)
  - [@aggregate = ( me, points, reducers ) ->](#aggregate---me-points-reducers---)
  - [@entries_of = ( me, ids = null ) ->](#entries_of---me-ids--null---)
  - [@entry_of = ( me, id ) ->](#entry_of---me-id---)
  - [@find_entries_with_all_points = ( me, P... ) ->](#find_entries_with_all_points---me-p---)
  - [@find_entries_with_any_points = ( me, P... ) ->](#find_entries_with_any_points---me-p---)
  - [@find_ids_with_all_points = ( me, points ) ->](#find_ids_with_all_points---me-points---)
  - [@find_ids_with_any_points = ( me, points ) ->](#find_ids_with_any_points---me-points---)
  - [@find_names_with_all_points = ( me, points ) ->](#find_names_with_all_points---me-points---)
  - [@find_names_with_any_points   = ( me, P... ) ->](#find_names_with_any_points-----me-p---)
  - [@insert = ( me, entry ) ->](#insert---me-entry---)
  - [@interval_of  = ( me, id ) ->](#interval_of----me-id---)
  - [@intervals_from_points = ( me, points, mixins... ) ->](#intervals_from_points---me-points-mixins---)
  - [@intervals_of = ( me, ids = null ) ->](#intervals_of---me-ids--null---)
  - [@name_of = ( me, id ) ->](#name_of---me-id---)
  - [@names_of = ( me, ids = null ) ->](#names_of---me-ids--null---)
  - [@new = ( settings ) ->](#new---settings---)
  - [@remove = ( me, id ) ->](#remove---me-id---)
  - [@sort_entries = ( me, entries ) ->](#sort_entries---me-entries---)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

**Caveat** Below examples are all written in CoffeeScript.

# InterSkipList

## Background

(Skip Lists)[https://en.wikipedia.org/wiki/Skip_list], in particular Interval Skip Lists, are a great
alternative to the more classical trees of various kinds to organize data so that searching remains
performant even with large amounts of data. As for the technical backgrounds, those interested should head
for the Wikipedia article linked above, or for any of (the great videos on the
topic)[https://www.youtube.com/watch?v=IXRzBVUgGl8] available. Let me just say that skip lists are built
not in a deterministic way, but with a random factor thrown in, which is nifty because this technique
enables a simple design that is yet *probably* quite close to the 'ideal' structure for the data at hand.

The present module does not add anything to its underlying of the skip list proper, which is provided
by [atom-archive/interval-skip-list](https://github.com/atom-archive/interval-skip-list), a 100% JS module
that used to be used in the Atom Editor. It has since been replaced by another module that I chose not to
integrate as its use of C components makes installation inherently more complex and error-prone.

## Intended Usage and Audience

**InterSkipList focuses on providing a small API that is tailored to suit a number of use cases, first and
foremost to simplify and speed up dealing with contiguous and non-contiguous ranges of Unicode characters
(codepoints)**.

### An Example Using CSS Unicode-Range

To clarify this point, it is perhaps easiest to have a quick look at how CSS `unicode-range` works, why it
is a great tool to organize your HTML styling needs and what you can do with that concept outside of
HTML/CSS.

Here's an [example](https://24ways.org/2011/creating-custom-font-stacks-with-unicode-range) for using
`unicode-range` in CSS; the range is just a single codepoint (`U+26`) in this case; it defines an abstract
font family named `my-custom-font` that will be applied only to that single codepoint, the `&` ampersand,
Unicode character `0x26`:


```css
@font-face {
    font-family: 'my-custom-font';
    src: local('Baskerville');
    unicode-range: U+26; }

p {
  font-family: 'my-custom-font'; }
```

The real utility of this device only starts to shine, though, when we exploit the fact that CSS allows
(1)&nbsp;multiple (2)&nbsp; potentially overlapping (2)&nbsp;ranges of codepoints; it is then possible to
build hierarchies of ranges—for example such that lots of characters in a given text will be displayed with
a base font, more restricted ranges of characters in a more suitable font, and some single glyphs with an
even more specialized typeface. In CSS, you could write:


```css
@font-face {
    font-family: 'my-custom-font';
    src: local('Arial');
    unicode-range: U+0000-U+10FFFF; }

@font-face {
    font-family: 'my-custom-font';
    src: local('Sun-ExtA');
    unicode-range: U+4E00-U+9FFF; }

@font-face {
    font-family: 'my-custom-font';
    src: local('Baskerville');
    unicode-range: U+26; }

p {
  font-family: 'my-custom-font'; }
```

which will display the text `<p>A&人</p>` using Arial for the `A`, Baskerville for the `&`, and Sun-ExtA for
the `人` glyphs.

### Same Example Using InterSkipList

Let's have a look at how to rewrite the gist of the above CSS rules in CoffeeScript using InterSkipList:

```coffee
# Create a SkipList `sample`:
sample = ISL.new()

# Insert 3 contiguous intervals; we'll use the `name`s momentarily:
ISL.insert sample, { lo: 0x0000, hi: 0x10ffff, name: 'base',      font_family: 'Arial',        }
ISL.insert sample, { lo: 0x4e00, hi:   0x9fff, name: 'cjk',       font_family: 'Sun-ExtA',     }
ISL.insert sample, { lo:   0x26, hi:     0x26, name: 'ampersand', font_family: 'Baskerville',  }
```

We have named the intervals with terms that suggest their scope.

> Observe that the `cjk` (i.e. 'Chinese, Japanese, Korean') range is not nearly exhaustive w.r.t. Unicode's
> character repertoire—for example, there are over 42,000 more CJK characters in the range `0x20000 ..
> 0x2a6df`. As a general rule, when you want to work with a subset of Unicode codepoints for a specific
> purpose (e.g. 'all the characters needed to write French', or 'uppercase Latin letters, with and without
> diacritics'), you will neither get only characters from a single, contiguous range, nor will sorting
> naïvely by codepoint values (like 26<sub>16</sub> = 38<sub>10</sub>) necessarily yield dictionary order.
> The 'Basic Latin' (ASCII) block is more the exception than the rule. We'll get to talk about
> non-contiguous ranges in a moment.

Having created and populated the `sample` interval skiplist, we can now go and query the data with one of
the 'find' methods. There are six of these, and they're named after the pattern

```
     ┌─────────┐
     │  names  │      ┌─────┐
find │   ids   │ with │ all │ points
     │ entries │      │ any │
     └─────────┘      └─────┘
```

When using the `find` methods, you can give any number of points; if you query for more than one point you
have to pass a list of values; codepoints may be given as numbers or as single-character texts. When using
several probes, the `all` methods will only return data for those intervals that contain each single probe,
and the `any` methods will return data for those intervals that contain at least one probe. When you query
for a single point, there is no distinction between the two.

Here we retrieve the names of the intervals that contain, respectively, one of the three codepoints `'A'`,
`'&'` and `'人'`:

```coffee
ISL.find_names_with_all_points samples, 'A' # --> [ 'base', ]
ISL.find_names_with_all_points samples, '&' # --> [ 'base', 'ampersand', ]
ISL.find_names_with_all_points samples, '人' # --> [ 'base', 'cjk', ]
```

The results returned by the `find` methods will always keep the order in which intervals were added to
the interval skip list structure; this is important for consistent results and for rule application.

Let's look at 'entries'—those are the JS objects we passed in for each interval; upon insertion, they'll
be amended with a few essential attributes (an ID, an insertion order index, and the size of the interval):

```coffee
base_entry =
  lo:               0
  hi:               1114111
  name:             'base'
  font_family:      'Arial'
  idx:              0
  id:               'latin[0]'
  size:             1114112
ampersand_entry =
  lo:               38
  hi:               38
  name:             'ampersand'
  font_family:      'Baskerville'
  idx:              2
  id:               'ampersand[0]'
  size:             1
cjk_entry =
  lo:               19968
  hi:               40959
  name:             'cjk'
  font_family:      'Sun-ExtA'
  idx:              1
  id:               'cjk[0]'
  size:             20992
```

The above data structures will be returned by the methods `ISL.entries_of`, `ISL.entry_of`,
`ISL.find_entries_with_all_points` and `ISL.find_entries_with_any_points`. Using these methods brings us one
step closer to the implementation of a CSS-Unicode-Range-like functionality; however, when you query the
data for a given codepoint and get back five or ten objects with lots of data each, that task may become a
little cumbersome. But do not fear, there's a convenience method that can help a great deal:


```coffee
# Test the rules with our sample characters:
ISL.aggregate sample, 'A'  # --> { name: 'base', font_family: 'Arial' }
ISL.aggregate sample, '&'  # --> { name: 'ampersand', font_family: 'Baskerville' }
ISL.aggregate sample, '人' # --> { name: 'cjk', font_family: 'Sun-ExtA' }
```

The above demonstrates the basic functionality of `aggregate`:

* it finds applicable entries by executing `find_entries_with_all_points`—that means you can pass in one or
  any number of points, and the returned structure will give you a lowest-common-denominator description.

* it then iterates over the key/value pairs of all entries found, in insertion order, skipping the keys
  `idx`, `id`, `lo`, `hi` and `size` (unless told otherwise), and assigns the values to the result (again
  unless told otherwise); since assignment is done in interval insertion order, attributes of later entries
  will replace attributes of earlier entries. This is essentially how CSS works (otherwise equivalent rules that come later in the stylesheet win over earlier
  ones), and it is also how `Object.assign` works (for which reason it is dubbed 'assign' mode).

* You may configure exactly how aggregation proceeds on a per-element basis. Just pass in a third argument
  whose keys are interval entry attribute keys and whose values describe the mode of operation. You can
  choose between
  * `'include'` (to include a key/value pair otherwise skipped),
  * `'skip'` (to omit an key/value pair otherwise included)
  * `'assign'` (to use 'assign' mode, as described above)
  * `'list'` (to build a list of all occurring values under that key)
  * `'add'` (to add up all numeric values under that key)
  * `'average'` (to get the average numeric value under that key)

  You can also pass in, say, `'*': 'list'` to use 'list' mode as a default for all elements not configured
  otherwise.

# Example 1

In this example, we build an Interval SkipList `isl` from some ASCII characters:

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
## @entry_of = ( me, id ) ->
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
## @name_of = ( me, id ) ->
## @names_of = ( me, ids = null ) ->
## @new = ( settings ) ->
## @remove = ( me, id ) ->
## @sort_entries = ( me, entries ) ->





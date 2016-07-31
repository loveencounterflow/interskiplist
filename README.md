



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
  - [Background](#background)
  - [Intended Usage and Audience](#intended-usage-and-audience)
    - [An Example Using CSS Unicode-Range](#an-example-using-css-unicode-range)
    - [Same Example Using InterSkipList](#same-example-using-interskiplist)
  - [Discontinuous Ranges](#discontinuous-ranges)
  - [Special Keys of Interval Entries](#special-keys-of-interval-entries)
  - [Tagging](#tagging)
- [API](#api)
  - [@aggregate = ( me, points, reducers ) ->](#aggregate---me-points-reducers---)
  - [@entries_of = ( me, ids = null ) ->](#entries_of---me-ids--null---)
  - [@entry_of = ( me, id ) ->](#entry_of---me-id---)
  - [@add = ( me, entry ) ->](#add---me-entry---)
  - [@interval_of  = ( me, id ) ->](#interval_of----me-id---)
  - [@intervals_from_points = ( me, points, mixins... ) ->](#intervals_from_points---me-points-mixins---)
  - [@intervals_of = ( me, ids = null ) ->](#intervals_of---me-ids--null---)
  - [@name_of = ( me, id ) ->](#name_of---me-id---)
  - [@names_of = ( me, ids = null ) ->](#names_of---me-ids--null---)
  - [@new = ( settings ) ->](#new---settings---)
  - [@remove = ( me, id ) ->](#remove---me-id---)
  - [@sort_entries = ( me, entries ) ->](#sort_entries---me-entries---)
  - [@find_ids       = ( me, point ) ->](#find_ids---------me-point---)
  - [@find_intervals = ( me, point ) ->](#find_intervals---me-point---)
  - [@find_entries   = ( me, point ) ->](#find_entries-----me-point---)
  - [@find_names     = ( me, point ) ->](#find_names-------me-point---)
  - [@find_ids_with_all_points = ( me, points ) ->](#find_ids_with_all_points---me-points---)
  - [@find_entries_with_all_points = ( me, P... ) ->](#find_entries_with_all_points---me-p---)
  - [@find_names_with_all_points = ( me, points ) ->](#find_names_with_all_points---me-points---)
  - [@find_ids_with_any_points = ( me, points ) ->](#find_ids_with_any_points---me-points---)
  - [@find_entries_with_any_points = ( me, P... ) ->](#find_entries_with_any_points---me-p---)
  - [@find_names_with_any_points   = ( me, P... ) ->](#find_names_with_any_points-----me-p---)

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
ISL.add sample, { lo: 0x0000, hi: 0x10ffff, name: 'base',      font_family: 'Arial',        }
ISL.add sample, { lo: 0x4e00, hi:   0x9fff, name: 'cjk',       font_family: 'Sun-ExtA',     }
ISL.add sample, { lo:   0x26, hi:     0x26, name: 'ampersand', font_family: 'Baskerville',  }
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
     ┌───────────┐ ⎛                     ⎞
     │    ids    │ ⎜      ┌─────┐        ⎟
     │   names   │ ⎜      │ all │        ⎟
find │ intervals │ ⎜ with │     │ points ⎟
     │  entries  │ ⎜      │ any │        ⎟
     └───────────┘ ⎝      └─────┘        ⎠
```

When using the mthods with the shorter names (`find_ids`, `find_names` &c), you can give a single point.
When using the methods with the longer names (`find_ids_with_any_points`, `find_names_with_all_points` &c)
you can pass any number of points. If you query for more than one point you have to pass a list of values;
codepoints may be given as numbers or as single-character texts. When using several probes, the `all`
methods will only return data for those intervals that contain each single probe, and the `any` methods will
return data for those intervals that contain at least one of the probes. When you query for a single point,
there is no distinction between the `any` and the `all` series of methods.

Here we retrieve the names of the intervals that contain, respectively, one of the three codepoints `'A'`,
`'&'` and `'人'`:

```coffee
ISL.find_names samples, 'A' # --> [ 'base', ]
ISL.find_names samples, '&' # --> [ 'base', 'ampersand', ]
ISL.find_names samples, '人' # --> [ 'base', 'cjk', ]
```

The results returned by the `find` methods will always keep the order in which intervals were added to the
interval skip list structure (addion order); this is important for consistent results and for rule
application. Because addion order is preserved, we can be confident that for each of the codepoints
queried, the 'most applicable' `name` property will always come *last* in the results—provided you ordered
interval addions from the general to the specific.

> **Note** For a while I considered to order results primarily by interval size, larger intervals coming
> first and single-point intervals coming last (and thereby overriding larger intervals). However logical
> that looks, interval-size-as-priority clearly breaks down when we move from (contiguous) intervals to
> (discontinuous) ranges: imagine a range `x` that includes some codepoint `A` as well as, say, an
> additional additional 9 codepoints hundreds or thousands of positions away. Compare that to another range
> `y` that includes points `A` and `A+1` as well as 7 other codepoints somewhere else in the codespace.
> Then, when quering for `A`, should `x` win over `y` because it has fewer codepoints (1 as opposed to 2)
> *locally*? Or should `y` win because it has fewer codepoints (9 as compared to 10) *globally*?

> **Note** that specifically with names, 'keeping addion order' entails that methods like `find_names`
> will return lists of unique names each of which appears in the latest (strongest) position. This means
> that lists of names as returned by the API may be shorter than corresponding lists of IDs, intervals, or
> entries, and that it suffices to look at the last ID, name or entry to find the piece of data with the
> highest applicability.

Let's look at 'entries'—those are the JS objects we passed in for each interval; upon addion, they'll
be amended with a few essential attributes (an ID, an addion order index, and the size of the interval):

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

* it then iterates over the key/value pairs of all entries found, in addion order, skipping the keys
  `idx`, `id`, `lo`, `hi` and `size` (unless told otherwise), and assigns the values to the result (again
  unless told otherwise); since assignment is done in interval addion order, attributes of later entries
  will replace attributes of earlier entries. This is essentially how CSS works (otherwise equivalent rules that come later in the stylesheet win over earlier
  ones), and it is also how `Object.assign` works (for which reason it is dubbed 'assign' mode).

* You may configure exactly how aggregation proceeds on a per-element basis. Just pass in a third argument
  whose keys are interval entry attribute keys and whose values describe the mode of operation. You can
  choose between
  * `'include'` (to include a key/value pair otherwise skipped),
  * `'skip'` (to omit an key/value pair otherwise included)
  * `'assign'` (to use 'assign' mode, as described above)
  * `'list'` (to build a list of all occurring values under that key)
  * `'tag'` (to obtain a list of unique values; see section on tagging, below)
  * `'add'` (to add up all numeric values under that key)
  * `'average'` (to get the average numeric value under that key)
  * Lastly, you can pass in a function that accepts a list of `[ id, value, ]` pairs (and, optionally,
    the return value of `aggregate` and the list of entries). The values for keys so configured will
    be whatever the respective function returns.

  To set a mode for all keys not configured explicitly, use the `'*'` (asterisk) key.

Example:

```coffee
replacers = { '*': 'list', name: 'include', }
ISL.aggregate samples, 'A', replacers
ISL.aggregate samples, '&', replacers
ISL.aggregate samples, '人', replacers
```

Output:

```coffee
{ name: [ 'base' ], font_family: [ 'Arial' ] }
{ name: [ 'base', 'ampersand' ], font_family: [ 'Arial', 'Baskerville' ] }
{ name: [ 'base', 'cjk' ], font_family: [ 'Arial', 'Sun-ExtA' ] }
```

## Discontinuous Ranges

Contiguous intervals are great because they are simple: Save for the metadata, any given interval is fully
described by giving its lower and its upper bound, period. In real life, however, discontinuous ranges are
common. In Unicode, for example, CJK characters are split over no less than around 20 blocks (where a
Unicode 'block', in turn, *is* a contiguous interval of codepoints); accordingly, to add the information to
indicate 'this is a CJK codepoint', we have to add around 20 intervals to the skip list.

InterSkipList enables discontinuous ranges by way of the `name` attribute. It is quite simple: each interval
must have its own unique ID, but a name can be used for any number of intervals.

As an example, let's build a partial representation for 7bit US-ASCII (U+00 .. U+7F); we assign a
descriptive name to each interval:

```coffee
#...........................................................................................................
ascii = ISL.new()
ISL.add ascii, { lo: 0x00, hi: 0x7f, name: 'basic-latin', }
ISL.add ascii, { lo: 'a', hi: 'z', name: 'letter', }
ISL.add ascii, { lo: 'A', hi: 'Z', name: 'letter', }
ISL.add ascii, { lo: 'a', hi: 'z', name: 'lower', }
ISL.add ascii, { lo: 'A', hi: 'Z', name: 'upper', }
#...........................................................................................................
for chr in 'aeiouAEIOU'
  ISL.add ascii, { lo: chr, hi: chr, name: 'vowel', }
#...........................................................................................................
consonants = Array.from 'bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ'
for interval in ISL.intervals_from_points ascii, consonants, { name: 'consonant', }
  ISL.add ascii, interval
#...........................................................................................................
digits = Array.from '0123456789'
for interval in ISL.intervals_from_points ascii, digits, { name: 'digit', }
  ISL.add ascii, interval
```

The result of our efforts diagrammed:

```
               2               3               4               5               6               7
               0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef

basic-latin[0]             -----------------------------------------------------------------------------------]
letter[s]                                       [------------------------]      [------------------------]
upper                                           [------------------------]
lower                                                                           [------------------------]
vowels                                          H   H   H     H     H           H   H   H     H     H
consonants                                       [-] [-] [---] [---] [---]       [-] [-] [---] [---] [---]
digits                         [--------]
                !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz
```

Observe that even this simple application needs ranges that are composed of several intervals, since not
even ASCII letters can be described by a single lower and upper boundary.

We can now query for names; the last name in each list has been set flush right for ease of comparison:

```
ISL.find_names_with_all_points ascii, [ 'c'     , ] ---> [ 'basic-latin', 'letter', 'lower', 'consonant' ]
ISL.find_names_with_all_points ascii, [ 'C'     , ] ---> [ 'basic-latin', 'letter', 'upper', 'consonant' ]
ISL.find_names_with_all_points ascii, [ 'c', 'C', ] ---> [ 'basic-latin', 'letter',          'consonant' ]
ISL.find_names_with_all_points ascii, [ 'C', 'C', ] ---> [ 'basic-latin', 'letter', 'upper', 'consonant' ]
ISL.find_names_with_all_points ascii, [ 'C', 'A', ] ---> [ 'basic-latin', 'letter',              'upper' ]
ISL.find_names_with_all_points ascii, [ 'c', 'A', ] ---> [ 'basic-latin',                       'letter' ]
ISL.find_names_with_all_points ascii, [ 'A', 'e', ] ---> [ 'basic-latin', 'letter',              'vowel' ]
ISL.find_names_with_all_points ascii, [ 'i', 'e', ] ---> [ 'basic-latin', 'letter', 'lower',     'vowel' ]
ISL.find_names_with_all_points ascii, [ '2', 'e', ] ---> [                                 'basic-latin' ]
```

## Special Keys of Interval Entries

The following keys of entries are treated specially by InterSkipList:

* **`lo`**—indicates smallest member of interval.
* **`hi`**—indicates biggest member of interval.
* **`id`**—unique identifier of interval; set automatically where not given.
* **`idx`**—automatically assigned according to insertion order.
* **`size`**—automatically assigned to `hi - lo + 1`
* **`name`**—group name of interval; automatically set to `+` where not given.
* **`tag`**—aggregated in `tag` mode unless explicitly specified.

## Tagging

(to be written; some key points:)

* it can be a single string or a list of strings. All strings will be split by whitespace, so `'foo bar
  baz'` is equivalent to `[ 'foo', 'bar baz', ]` and `[ 'foo', 'bar', 'baz', ]`;
* each defines a 'mon-valued' attribute: 'false' where absent, 'true' where present
* `ISL.find_tags` returns a list of unique tags that are found in the interval entries that contain this
  point;
* `ISL.find_tags_with_all_points` returns a list of unique tags that are applicable to *all* the points
  given (intersection);
* `ISL.find_tags_with_any_points` returns a list of unique tags that are applicable to *any* the points
  given (union);
* tags preceded by a `-` (minus, hyphen) are interpreted as 'negative' or 'cancellation' tags.
  Negative tags cancel all appearances of namesake tags that appear before them in aggregated tag lists.
  The special `'-*'` (minus star) tag cancels out *all* tags that come before it.

# API

## @aggregate = ( me, points, reducers ) ->
## @entries_of = ( me, ids = null ) ->
## @entry_of = ( me, id ) ->
## @add = ( me, entry ) ->
## @interval_of  = ( me, id ) ->
## @intervals_from_points = ( me, points, mixins... ) ->
## @intervals_of = ( me, ids = null ) ->
## @name_of = ( me, id ) ->
## @names_of = ( me, ids = null ) ->
## @new = ( settings ) ->
## @remove = ( me, id ) ->
## @sort_entries = ( me, entries ) ->


## @find_ids       = ( me, point ) ->
## @find_intervals = ( me, point ) ->
## @find_entries   = ( me, point ) ->
## @find_names     = ( me, point ) ->

## @find_ids_with_all_points = ( me, points ) ->
## @find_entries_with_all_points = ( me, P... ) ->
## @find_names_with_all_points = ( me, points ) ->

## @find_ids_with_any_points = ( me, points ) ->
## @find_entries_with_any_points = ( me, P... ) ->
## @find_names_with_any_points   = ( me, P... ) ->



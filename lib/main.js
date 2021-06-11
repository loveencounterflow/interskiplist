(function() {
  //###########################################################################################################
  var CND, alert, append, as_number, as_numbers, badge, debug, echo, fuse, help, info, is_subset, isa, log, meld, mix, normalize_points, normalize_tag, reduce_tag, rpr, setting_keys_of_cover_and_intersect, sort_entries_by_insertion_order, sort_ids_by_insertion_order, type_of, types, unique, urge, validate, warn, whisper, σ_minus_א, σ_misfit, σ_plus_א,
    indexOf = [].indexOf;

  CND = require('cnd');

  rpr = CND.rpr.bind(CND);

  badge = 'INTERSKIPLIST';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  σ_plus_א = Symbol.for('+א');

  σ_minus_א = Symbol.for('-א');

  σ_misfit = Symbol.for('misfit');

  //...........................................................................................................
  ({mix} = require('multimix'));

  types = require('./types');

  ({isa, validate, type_of} = types.export());

  //-----------------------------------------------------------------------------------------------------------
  this.new = function(settings) {
    var R, isl_settings, substrate;
    if (settings != null) {
      throw new Error("settings not supported");
    }
    isl_settings = {
      minIndex: σ_minus_א,
      maxIndex: σ_plus_א,
      compare: function(a, b) {
        if (a === b && (a === σ_plus_א || a === σ_minus_א)) {
          return 0;
        }
        if ((a === σ_plus_א) || (b === σ_minus_א)) {
          return +1;
        }
        if ((a === σ_minus_א) || (b === σ_plus_א)) {
          return -1;
        }
        if (a > b) {
          return +1;
        }
        if (a < b) {
          return -1;
        }
        return 0;
      }
    };
    //.........................................................................................................
    substrate = new (require('interval-skip-list'))(isl_settings);
    substrate.toString = substrate.inspect = function() {
      return "{ interval-skip-list }";
    };
    //.........................................................................................................
    R = {
      '~isa': 'CND/interskiplist',
      '%self': substrate,
      'entry-by-ids': {},
      'idx-by-names': {},
      'ids-by-names': {},
      'name-by-ids': {},
      'idx-by-ids': {},
      'ids': [],
      'idx': -1,
      'min': null,
      'max': null,
      'fmin': null,
      'fmax': null,
      'indexes': {}
    };
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.copy = function(me) {
    var R, entry, i, len, name, ref;
    R = this.new();
    for (name in me['indexes']) {
      this.add_index(R, name);
    }
    ref = this.entries_of(me);
    for (i = 0, len = ref.length; i < len; i++) {
      entry = ref[i];
      this.add(R, CND.deep_copy(entry));
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.add = function(me, entry) {
    var arity, base, global_idx, group_idx, hi, id, lo, name, ref;
    if ((arity = arguments.length) !== 2) {
      /* TAINT currently we keep the identity of `entry` and amend it; wouldn't it be better to copy? or deep
       copy? it and then amend it? */
      throw new Error(`expected 2 arguments, got ${arity}`);
    }
    if (!isa.object(entry)) {
      throw new Error(`expected a POD, got a ${type_of(entry)}`);
    }
    ({lo, hi, id, name} = entry);
    if (lo == null) {
      throw new Error("expected setting for 'lo', found none");
    }
    if (hi == null) {
      throw new Error("expected setting for 'hi', found none");
    }
    lo = as_number(lo);
    hi = as_number(hi);
    if (name == null) {
      name = '+';
    }
    group_idx = (me['idx-by-names'][name] = ((ref = me['idx-by-names'][name]) != null ? ref : -1) + 1);
    global_idx = (me['idx'] += +1);
    if (id == null) {
      id = `${name}[${group_idx}]`;
    }
    entry['lo'] = lo;
    entry['hi'] = hi;
    entry['idx'] = global_idx;
    entry['id'] = id;
    entry['name'] = name;
    entry['size'] = hi - lo + 1;
    if (entry['tag'] != null) {
      entry['tag'] = normalize_tag(entry['tag']);
    }
    if (me['min'] == null) {
      me['min'] = lo;
    }
    me['min'] = Math.min(me['min'], lo);
    if (me['max'] == null) {
      me['max'] = hi;
    }
    me['max'] = Math.max(me['max'], lo);
    if (isa.float(lo)) {
      if (me['fmin'] == null) {
        me['fmin'] = lo;
      }
      me['fmin'] = Math.min(me['fmin'], lo);
    }
    if (isa.float(hi)) {
      if (me['fmax'] == null) {
        me['fmax'] = hi;
      }
      me['fmax'] = Math.max(me['fmax'], lo);
    }
    me['name-by-ids'][id] = name;
    me['idx-by-ids'][id] = global_idx;
    me['entry-by-ids'][id] = entry != null ? entry : null;
    ((base = me['ids-by-names'])[name] != null ? base[name] : base[name] = []).push(id);
    me['%self'].insert(id, lo, hi);
    me['ids'].push(id);
    //.........................................................................................................
    this._index_entry(me, entry);
    //.........................................................................................................
    return id;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.delete = function(me, id) {
    return me['%self'].remove(id);
  };

  // #===========================================================================================================
  // # SERIALIZATION
  // #-----------------------------------------------------------------------------------------------------------
  // @to_xjson = ( me ) ->
  //   R =
  //     'index-keys': ( key   for key       of me[ 'indexes'      ] )
  //     'entries':    ( entry for _, entry  of me[ 'entry-by-ids' ] )
  //   return CND.XJSON.stringify R, null, '  '

  // #-----------------------------------------------------------------------------------------------------------
  // @new_from_xjson = ( xjson ) ->
  //   description = CND.XJSON.parse xjson
  //   R           = @new()
  //   @add_index  R, key    for key   in description[ 'index-keys'  ]
  //   @add        R, entry  for entry in description[ 'entries'     ]
  //   return R

  //===========================================================================================================
  // INDEXING
  //-----------------------------------------------------------------------------------------------------------
  this.add_index = function(me, name) {
    if (me['indexes'][name] != null) {
      throw new Error(`index for ${rpr(name)} already exists`);
    }
    return me['indexes'][name] = {};
  };

  //-----------------------------------------------------------------------------------------------------------
  this.delete_index = function(me, name, fallback) {
    var R, ref;
    if (fallback === void 0) {
      fallback = σ_misfit;
    }
    R = (ref = me['indexes'][name]) != null ? ref : fallback;
    if (R === σ_misfit) {
      throw new Error(`no index for field ${rpr(name)}`);
    }
    delete me['indexes'][name];
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this.find_ids = function(me, name, value) {
    var R, index;
    if ((index = me['indexes'][name]) == null) {
      throw new Error(`no index for field ${rpr(name)}`);
    }
    if ((R = index[value]) == null) {
      return [];
    }
    return Object.assign([], R);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.find_entries = function(me, name, value) {
    var R, i, id, idx, len;
    R = this.find_ids(me, name, value);
    for (idx = i = 0, len = R.length; i < len; idx = ++i) {
      id = R[idx];
      R[idx] = me['entry-by-ids'][id];
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  this._index_entry = function(me, entry) {
    var i, id, index, indexes, len, name, ref, tag, value;
    ({id} = entry);
    //.........................................................................................................
    if ((indexes = me['indexes']) != null) {
      for (name in entry) {
        value = entry[name];
        if (!(index = indexes[name])) {
          continue;
        }
        /* TAINT this is a minimally viable product; indexing behavior should be configurable */
        if (name === 'tag') {
          ref = normalize_tag(value);
          for (i = 0, len = ref.length; i < len; i++) {
            tag = ref[i];
            (index[tag] != null ? index[tag] : index[tag] = []).push(id);
          }
        } else {
          (index[value] != null ? index[value] : index[value] = []).push(id);
        }
      }
    }
    //.........................................................................................................
    return null;
  };

  //===========================================================================================================
  // COVER AND INTERSECT
  //-----------------------------------------------------------------------------------------------------------
  this.match = function(me, points, settings = {}) {
    return this._match_or_intersect(me, 'match', points, settings);
  };

  this.intersect = function(me, points, settings = {}) {
    return this._match_or_intersect(me, 'intersect', points, settings);
  };

  //-----------------------------------------------------------------------------------------------------------
  this._match_or_intersect = function(me, mode, points, settings) {
    var R, entry, expected, got, keys, pick;
    // throw new Error "ISL.match, ISL.intersect on hold for revision"
    /* TAINT can probably be greatly simplified since advanced functionality here is not needed */
    if (!is_subset((keys = Object.keys(settings)), setting_keys_of_cover_and_intersect)) {
      expected = setting_keys_of_cover_and_intersect.join(', ');
      got = keys.join(', ');
      throw new Error(`expected settings out of ${expected}, got ${got}`);
    }
    ({pick} = settings);
    if (mode === 'match') {
      R = this._find_ids_with_all_points(me, points);
    } else {
      R = this._find_ids_with_any_points(me, points);
    }
    if (pick === 'id') {
      return R;
    }
    R = this.entries_of(me, R);
    if (pick != null) {
      R = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = R.length; i < len; i++) {
          entry = R[i];
          results.push(entry[pick]);
        }
        return results;
      })();
      if (pick === 'tag') {
        return reduce_tag(R);
      }
    }
    return fuse(R);
  };

  //-----------------------------------------------------------------------------------------------------------
  setting_keys_of_cover_and_intersect = ['pick'];

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  this.entries_of = function(me, ids = null) {
    var R, _, entry, i, id, len;
    if (ids == null) {
      R = (function() {
        var ref, results;
        ref = me['entry-by-ids'];
        results = [];
        for (_ in ref) {
          entry = ref[_];
          results.push(entry);
        }
        return results;
      })();
    } else {
      R = [];
      for (i = 0, len = ids.length; i < len; i++) {
        id = ids[i];
        if ((entry = me['entry-by-ids'][id]) == null) {
          throw new Error(`unknown ID ${rpr(id)}`);
        }
        R.push(entry);
      }
    }
    return sort_entries_by_insertion_order(me, R);
  };

  //-----------------------------------------------------------------------------------------------------------
  this._find_ids_with_any_points = function(me, points) {
    var R, i, id, ids, j, len, len1, point;
    points = normalize_points(points);
    if (points.length < 2) {
      return me['%self'].findContaining(...points);
    }
    R = new Set();
    for (i = 0, len = points.length; i < len; i++) {
      point = points[i];
      ids = me['%self'].findContaining(point);
      for (j = 0, len1 = ids.length; j < len1; j++) {
        id = ids[j];
        R.add(id);
      }
    }
    return sort_ids_by_insertion_order(me, Array.from(R));
  };

  //-----------------------------------------------------------------------------------------------------------
  this._find_ids_with_all_points = function(me, points) {
    points = normalize_points(points);
    return me['%self'].findContaining(...points);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.intervals_from_points = function(me, points, ...mixins) {
    var R, i, last_hi, last_lo, last_point, len, mixin, point;
    mixin = function(lohi) {
      if (!(mixins.length > 0)) {
        return lohi;
      }
      return Object.assign({}, ...mixins, lohi);
    };
    if (!isa.list(points)) {
      points = [points];
    }
    points = unique(as_numbers(points));
    points.sort(function(a, b) {
      if (a > b) {
        return +1;
      }
      if (a < b) {
        return -1;
      }
      return 0;
    });
    R = [];
    last_point = null;
    last_lo = null;
    last_hi = null;
    for (i = 0, len = points.length; i < len; i++) {
      point = points[i];
      if (last_lo == null) {
        last_lo = point;
        last_hi = point;
        last_point = point;
        continue;
      }
      if (point === last_point + 1) {
        last_hi = point;
        last_point = point;
        continue;
      }
      R.push(mixin({
        lo: last_lo,
        hi: last_hi
      }));
      last_lo = point;
      last_hi = point;
      last_point = point;
    }
    if ((last_lo != null) && (last_hi != null)) {
      R.push(mixin({
        lo: last_lo,
        hi: last_hi
      }));
    }
    return R;
  };

  //===========================================================================================================
  // AGGREGATION
  //-----------------------------------------------------------------------------------------------------------
  this.aggregate = function(me, point, reducers = null) {
    return (this.aggregate.use(me, reducers))(point);
  };

  //-----------------------------------------------------------------------------------------------------------
  this.aggregate.use = (me, reducers, settings = {}) => {
    /* TAINT this part must be rewritten */
    var cache, fields, keys, memoize, mix_entries_of_point, mixin, mixins, my_mix, ref;
    if (!is_subset((keys = Object.keys(settings)), ['memoize'])) {
      throw new Error(`unknown keys in ${rpr(keys)}`);
    }
    //.........................................................................................................
    if ((memoize = (ref = settings['memoize']) != null ? ref : true)) {
      cache = {};
    } else {
      cache = null;
    }
    //.........................................................................................................
    if ((reducers == null) || (Object.keys(reducers)).length === 0) {
      my_mix = this.aggregate._mix;
    } else {
      mixins = [{}];
      mixins.push(this.aggregate._reducers);
      if (reducers != null) {
        mixins.push(reducers);
      }
      fields = Object.assign({}, ...((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = mixins.length; i < len; i++) {
          mixin = mixins[i];
          if (mixin.fields != null) {
            results.push(mixin.fields);
          }
        }
        return results;
      })()));
      reducers = Object.assign(...mixins);
      reducers['fields'] = fields;
      my_mix = mix.use(reducers);
    }
    //.........................................................................................................
    mix_entries_of_point = (point) => {
      var entries, point_count;
      point_count = (isa.list(point)) ? point.length : 1;
      if (point_count !== 1) {
        throw new Error(`need single point, got ${point_count}`);
      }
      entries = this.entries_of(me, this._find_ids_with_any_points(me, point));
      return my_mix(...entries);
    };
    if (!memoize) {
      //.........................................................................................................
      return mix_entries_of_point;
    }
    //.........................................................................................................
    return (point) => {
      var R;
      if ((R = cache[point]) != null) {
        return R;
      }
      return cache[point] = mix_entries_of_point(point);
    };
  };

  //-----------------------------------------------------------------------------------------------------------
  this.aggregate._reducers = {
    fields: {
      idx: 'skip',
      id: 'skip',
      name: 'skip',
      lo: 'skip',
      hi: 'skip',
      size: 'skip',
      tag: 'tag'
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  this.aggregate._mix = mix.use(this.aggregate._reducers);

  //===========================================================================================================
  // HELPERS
  //-----------------------------------------------------------------------------------------------------------
  sort_entries_by_insertion_order = function(me, entries) {
    entries.sort(function(a, b) {
      if (a['idx'] > b['idx']) {
        return +1;
      }
      if (a['idx'] < b['idx']) {
        return -1;
      }
      return 0;
    });
    return entries;
  };

  //-----------------------------------------------------------------------------------------------------------
  sort_ids_by_insertion_order = function(me, ids) {
    var idxs;
    idxs = me['idx-by-ids'];
    ids.sort(function(a, b) {
      if (idxs[a] > idxs[b]) {
        return +1;
      }
      if (idxs[a] < idxs[b]) {
        return -1;
      }
      return 0;
    });
    return ids;
  };

  //-----------------------------------------------------------------------------------------------------------
  as_number = function(x) {
    var length, type;
    if ((x === (-2e308) || x === (+2e308)) || isa.float(x)) {
      return x;
    }
    if ((type = type_of(x)) !== 'text') {
      throw new Error(`expected number or single character text, got a ${type}`);
    }
    if ((length = (Array.from(x)).length) !== 1) {
      throw new Error(`expected single character text, got one of length ${length}`);
    }
    return x.codePointAt(0);
  };

  //-----------------------------------------------------------------------------------------------------------
  as_numbers = function(list) {
    var i, len, results, x;
    results = [];
    for (i = 0, len = list.length; i < len; i++) {
      x = list[i];
      results.push(as_number(x));
    }
    return results;
  };

  //-----------------------------------------------------------------------------------------------------------
  normalize_points = function(points) {
    if (!isa.list(points)) {
      points = [points];
    }
    return as_numbers(points);
  };

  //-----------------------------------------------------------------------------------------------------------
  normalize_tag = function(tag) {
    var R, i, len, t;
    if (!isa.list(tag)) {
      /* Given a single string or a list of strings, return a new list that contains all whitespace-delimited
       words in the strings */
      return normalize_tag([tag]);
    }
    R = [];
    for (i = 0, len = tag.length; i < len; i++) {
      t = tag[i];
      if (t.length === 0) {
        continue;
      }
      R.splice(R.length, 0, ...(t.split(/\s+/)));
    }
    /* TAINT consider to return `unique R` instead */
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  unique = function(list) {
    /* Return a copy of `list´ that only contains the last occurrence of each value */
    /* TAINT consider to modify, not copy `list` */
    var R, element, i, idx, ref, seen;
    seen = new Set();
    R = [];
    for (idx = i = ref = list.length - 1; i >= 0; idx = i += -1) {
      element = list[idx];
      if (seen.has(element)) {
        continue;
      }
      seen.add(element);
      R.unshift(element);
    }
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  append = function(a, b) {
    /* Append elements of list `b` to list `a` */
    /* TAINT JS has `[]::concat` */
    a.splice(a.length, 0, ...b);
    return a;
  };

  //-----------------------------------------------------------------------------------------------------------
  meld = function(list, value) {
    /* When `value` is a list, `append` it to `list`; else, `push` `value` to `list` */
    if (isa.list(value)) {
      append(list, value);
    } else {
      list.push(value);
    }
    return list;
  };

  //-----------------------------------------------------------------------------------------------------------
  fuse = function(list) {
    /* Flatten `list`, then apply `unique` to it. Does not copy `list` but modifies it */
    var R, element, i, len;
    R = [];
    for (i = 0, len = list.length; i < len; i++) {
      element = list[i];
      meld(R, element);
    }
    R = unique(R);
    list.splice(0, list.length, ...R);
    return list;
  };

  //-----------------------------------------------------------------------------------------------------------
  reduce_tag = function(raw) {
    var R, exclude, i, idx, ref, source, tag;
    source = fuse(raw);
    R = [];
    exclude = null;
//.........................................................................................................
    for (idx = i = ref = source.length - 1; i >= 0; idx = i += -1) {
      tag = source[idx];
      if ((exclude != null) && exclude.has(tag)) {
        continue;
      }
      if (tag.startsWith('-')) {
        if (tag === '-*') {
          break;
        }
        (exclude != null ? exclude : exclude = new Set()).add(tag.slice(1));
        continue;
      }
      R.unshift(tag);
    }
    //.........................................................................................................
    return R;
  };

  //-----------------------------------------------------------------------------------------------------------
  is_subset = function(subset, superset) {
    /* `is_subset subset, superset` returns whether `subset` is a subset of `superset`; this is true if each
     element of `subset` is also an element of `superset`. */
    var done, element, i, iterator, len, type_of_sub, type_of_super, value;
    type_of_sub = type_of(subset);
    type_of_super = type_of(superset);
    if (type_of_sub !== type_of_super) {
      throw new Error(`expected two arguments of same type, got ${type_of_sub} and ${type_of_super}`);
    }
    switch (type_of_sub) {
      case 'list':
        if (!(subset.length <= superset.length)) {
          return false;
        }
        for (i = 0, len = subset.length; i < len; i++) {
          element = subset[i];
          if (indexOf.call(superset, element) < 0) {
            return false;
          }
        }
        return true;
      case 'set':
        if (!(subset.size <= superset.size)) {
          return false;
        }
        iterator = subset.values();
        while (true) {
          ({value, done} = iterator.next());
          if (done) {
            return true;
          }
          if (!superset.has(value)) {
            return false;
          }
        }
        // for element in
        //   return false unless element in subset
        return true;
      default:
        throw new Error(`expected lists or sets, got ${type_of_sub} and ${type_of_super}`);
    }
    return null;
  };

}).call(this);

//# sourceMappingURL=main.js.map
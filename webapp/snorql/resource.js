// Generated by CoffeeScript 1.10.0
(function() {
  var direct, direct_table, enter_direct, enter_inverse, inverse, inverse_table, o_format, p_format;

  p_format = function(predicate) {
    var match;
    match = predicate.match(/(.*):(.*)/);
    return "<span class='small prefix' title='" + D2R_namespacePrefixes[match[1]] + "'>" + match[1] + ":</span><span>" + match[2] + "</span>";
  };

  o_format = function(object) {
    var match;
    match = object.match(/(.*)\^\^(http:\/\/.*)/);
    if (match !== null) {
      return "<span class='literal'>" + match[1] + "</span> <span class='small literal' title='" + match[2] + "'>(" + (match[2].slice(match[2].indexOf('#') + 1)) + ")</span>";
    } else if (object.indexOf("http") === 0) {
      return "<span class='uri'><<a href='" + object + "'>" + object + "</a>></span>";
    } else {
      return "<span class='literal'>" + object + "</span>";
    }
  };


  /* Resource label and URI
   */

  d3.select('#header #title').html(resource.label);

  d3.select('#header #subtitle').text(resource.uri);


  /* Triples list
   */

  direct_table = d3.select('#direct');

  inverse_table = d3.select('#inverse');


  /* Direct
   */

  if (triples_data.direct.length === 0) {
    direct_table.append('tr').append('td').text('No Direct triples defined.');
  }

  triples_data.direct.sort(function(a, b) {
    if (a.type === 'Data property' && b.type === 'Data property') {
      if (a.predicate === 'dc:title') {
        return -1;
      } else if (b.predicate === 'dc:title') {
        return 1;
      } else if (a.predicate === 'rdfs:label') {
        return -1;
      } else if (b.predicate === 'rdfs:label') {
        return 1;
      }
    } else if (a.type === 'Data property') {
      return -1;
    } else {
      return 1;
    }
  });

  direct = direct_table.selectAll('tr').data(triples_data.direct);

  enter_direct = direct.enter().append('tr');

  enter_direct.append('td').attr({
    "class": 'predicate'
  });

  enter_direct.append('td').attr({
    "class": 'object'
  });

  direct.select('.predicate').html(function(d) {
    return p_format(d.predicate);
  });

  direct.select('.object').html(function(d) {
    return o_format(d.object);
  });


  /* Inverse
   */

  if (triples_data.inverse.length === 0) {
    inverse_table.append('tr').append('td').attr({
      "class": 'literal'
    }).text('No Inverse triples defined.');
  }

  inverse = inverse_table.selectAll('tr').data(triples_data.inverse);

  enter_inverse = inverse.enter().append('tr');

  enter_inverse.append('td').attr({
    "class": 'predicate'
  });

  enter_inverse.append('td').attr({
    "class": 'object'
  });

  inverse.select('.predicate').html(function(d) {
    return p_format(d.predicate);
  });

  inverse.select('.object').html(function(d) {
    return o_format(d.object);
  });

}).call(this);

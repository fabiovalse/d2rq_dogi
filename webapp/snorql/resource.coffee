p_format = (predicate) ->
  "<a href='#{predicate.uri}' title='#{predicate.uri}'><span class='small prefix#{if predicate.prefix is 'dogi:' then ' dogi_prefix' else ''}'>#{predicate.prefix}</span><span class='suffix'>#{predicate.suffix}</span><a>"

o_format = (object) ->
  match = object.value.match /(.*)\^\^(http:\/\/.*)/

  if match isnt null
    "<span class='literal'>#{match[1]}</span> <span class='small literal' title='#{match[2]}'>(<a target='_blank' class='datatype' href='#{match[2]}'>#{match[2].slice(match[2].indexOf('#')+1)}</a>)</span>"
  else if object.isURI
    for k,v of D2R_namespacePrefixes
      if object.value.indexOf(v) is 0
        return "<a href='#{object.value}' title='#{object.value}'><span class='small prefix#{if k is 'dogi' then ' dogi_prefix' else ''}'>#{k}:</span><span class='suffix'>#{object.value.slice(v.length)}</span><a>"
    "<span class='uri'><<a href='#{object.value}'>#{object.value}</a>></span>"
  else if object.value.indexOf("http") is 0
    "<span class='uri'><a href='#{object.value}'>#{object.value}</a></span>"
  else
    "<span class='literal'>#{object.value}</span>"

### Resource label and URI
###
d3.select '#header .title'
  .html resource.label

d3.select '#header .subtitle'
  .text resource.uri

### Triples list
###
direct_table = d3.select '#direct'
inverse_table = d3.select '#inverse'

### Direct
###
if triples_data.direct.length is 0
  direct_table.append 'tr'
    .append 'td'
      .text 'No Direct triples defined.'

# sorting
triples_data.direct.sort (a,b) ->
  if a.type is 'Data property' and b.type is 'Data property'
    if (a.predicate.prefix+a.predicate.suffix) < (b.predicate.prefix+a.predicate.suffix)
      -1
    else
      1
  else if a.type is 'Object property' and b.type is 'Object property'
    if (a.predicate.prefix+a.predicate.suffix) < (b.predicate.prefix+a.predicate.suffix)
      -1
    else
      1
  else if a.type is 'Data property'
    -1
  else
    1

direct = direct_table.selectAll 'tr'
  .data triples_data.direct

enter_direct = direct.enter().append 'tr'

enter_direct.append 'td'
  .attr
    class: 'predicate'

enter_direct.append 'td'
  .attr
    class: 'object'

direct.select '.predicate'
  .html (d) -> p_format d.predicate

direct.select '.object'
  .html (d) -> o_format d.object

### Inverse
###
if triples_data.inverse.length is 0
  inverse_table.append 'tr'
    .append 'td'
      .attr
        class: 'literal'
      .text 'No Inverse triples defined.'

inverse = inverse_table.selectAll 'tr'
  .data triples_data.inverse

enter_inverse = inverse.enter().append 'tr'

enter_inverse.append 'td'
  .attr
    class: 'predicate'

enter_inverse.append 'td'
  .attr
    class: 'object'

inverse.select '.predicate'
  .html (d) -> p_format d.predicate

inverse.select '.object'
  .html (d) -> o_format d.object
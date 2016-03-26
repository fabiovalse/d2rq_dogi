p_format = (predicate) ->
  match = predicate.match /(.*):(.*)/  

  "<span class='small prefix' title='#{D2R_namespacePrefixes[match[1]]}'>#{match[1]}:</span><span>#{match[2]}</span>"

o_format = (object) ->
  match = object.match /(.*)\^\^(http:\/\/.*)/

  if match isnt null
    "<span class='literal'>#{match[1]}</span> <span class='small literal' title='#{match[2]}'>(#{match[2].slice(match[2].indexOf('#')+1)})</span>"
  else if object.indexOf("http") is 0
    "<span class='uri'><<a href='#{object}'>#{object}</a>></span>"
  else
    "<span class='literal'>#{object}</span>"

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

triples_data.direct.sort (a,b) ->
  if a.type is 'Data property' and b.type is 'Data property'
    if a.predicate is 'dc:title'
      -1
    else if b.predicate is 'dc:title'
      1
    else if a.predicate is 'rdfs:label'
      -1
    else if b.predicate is 'rdfs:label'
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
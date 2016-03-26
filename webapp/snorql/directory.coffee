###d3.select '#central_section_title'
  .text "Some examples of resources classified as #{data[0].uri.split('/').slice(-2)[0]}:"###

container = d3.select '#examples'

examples = container.selectAll '.example'
  .data data.sort (a,b) ->
    a = a.uri.split('/')
    b = b.uri.split('/')
    d3.ascending parseInt(a[a.length-1]), parseInt(b[b.length-1])

enter_examples = examples.enter()
  .append 'div'
    .attr
      class: 'example'

enter_examples.append 'div'
  .html (d) -> d.label

enter_examples.append 'div'
    .attr
      class: 'uri'
    .append 'a'
      .attr
        href: (d) -> d.uri
      .text (d) -> d.uri

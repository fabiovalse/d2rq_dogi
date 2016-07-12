margin = {top: 20, right: 20, bottom: 30, left: 50}
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

svg = d3.select 'svg'
  .attr
    width: width+margin.left+margin.right
    height: height+margin.top+margin.bottom
  .append 'g'
    .attr
      transform: "translate(#{margin.left}, #{margin.top})"

x = d3.scale.sqrt()
  .range [0, width]

y = d3.scale.linear()
  .range [height, 0]

x_axis = d3.svg.axis()
  .scale x

x_axis2 = d3.svg.axis()
  .scale x

y_axis = d3.svg.axis()
  .scale y
  .orient 'left'

line = d3.svg.line()
  .x (d,i) -> x i
  .y (d) -> y d.cont.value

d3.json 'data.json', (error, data) ->

  x.domain(d3.extent(data.results.bindings, (d,i) -> i))
  y.domain(d3.extent(data.results.bindings, (d) -> parseInt(d.cont.value)))

  x_axis
    .tickValues [0, data.results.bindings.length*0.01, data.results.bindings.length*0.02, data.results.bindings.length*0.05, data.results.bindings.length*0.1, data.results.bindings.length*0.2, data.results.bindings.length*0.25, data.results.bindings.length*0.5, data.results.bindings.length*0.75, data.results.bindings.length]
    .tickFormat (d) -> if d isnt 0 then "#{d/data.results.bindings.length*100}%" else ''

  x_axis2
    .tickValues [0, data.results.bindings.length*0.01, data.results.bindings.length*0.02, data.results.bindings.length*0.05, data.results.bindings.length*0.1, data.results.bindings.length*0.2, data.results.bindings.length*0.25, data.results.bindings.length*0.5, data.results.bindings.length*0.75, data.results.bindings.length]
    .tickFormat (d) -> if d isnt 0 then "(#{d})" else ''

  svg.append 'g'
    .attr 
      class: 'x2 axis'
      transform: "translate(0, #{height+10})"
    .call x_axis2

  svg.append 'g'
    .attr 
      class: 'x axis'
      transform: "translate(0, #{height})"
    .call x_axis
      .append 'text'
        .attr
          x: width-40
          y: -15
        .text '% Agents'

  svg.append 'g'
    .attr 
      class: 'y axis'
    .call y_axis
      .append 'text'
        .attr
          transform: 'rotate(-90)'
          y: 15
          dy: '.71em'
          'text-anchor': 'end'
        .text '# Publications'

  svg.append 'path'
    .datum data.results.bindings
    .attr
      class: 'line'
      d: line

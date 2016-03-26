left_padding = 150
class_height = 30
bar_height = 15
classes_amounts = {}

svg = d3.select 'svg'
  .attr
    height: data.length*class_height
  .append 'g'
    .attr
      transform: "translate(0, 20)"

d3.json "#{home_url}snorql/data/classes.json", (classes_data) ->

  for i,c of classes_data.results.bindings
    key = c.c.value.split('/').slice(-1)[0].replace('#', '')

    if key is 'Person' or key is 'Organization'
      key = 'Agent'
    else if key is 'Location'
      key = 'Country'

    classes_amounts[key] = parseInt(c.cont.value)

  x = d3.scale.pow()
    .exponent(0.3)
    .range [0, d3.select('#main').node().getBoundingClientRect().width/2]
    .domain [0, d3.max(classes_data.results.bindings, (d) -> parseInt(d.cont.value))]

  y = d3.scale.ordinal()
    .rangeRoundBands [0, 300], .5
    .domain data.map (d,i) -> i

  ### Classes
  ###
  classes = d3.select('#classes').selectAll 'li'
    .data data

  enter_classes = classes.enter().append 'li'
  
  enter_classes.append 'span'
    .append 'a'
      .attr
        href: (d) -> "#{home_url}directory/#{d.table}"
      .text (d) -> d.class

  enter_classes.append 'span'
    .text (d) -> ": #{d.desc}"

  ### Bar-chart
  ###
  classes = svg.selectAll '.class'
    .data data

  classes.enter().append 'g'
    .attr
      class: 'class'
  
  classes.append 'rect'
    .attr
      class: 'bar'
      x: left_padding
      y: (d,i) -> y i
      width: (d) -> x classes_amounts[d.class.replace(/ /g, '')]
      height: bar_height

  classes.append 'text'
    .attr
      class: 'title'
      'text-anchor': 'end'
      x: left_padding - 10
      y: (d,i) -> y(i) + bar_height/1.4
    .text (d) -> d.class
    .append 'title'
      .text (d) -> "#{d.desc}"

  classes.append 'text'
    .attr
      class: 'bar_amount'
      x: (d) -> left_padding + x(classes_amounts[d.class.replace(/ /g, '')]) + 5
      y: (d,i) -> y(i) + bar_height/1.4
    .text (d) -> classes_amounts[d.class.replace(/ /g, '')]
    .append 'title'
      .text (d) -> "#{classes_amounts[d.class.replace(/ /g, '')]} instances of type #{d.class}"
  
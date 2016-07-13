margin = 40
bar_height = 20
data_ticks = [1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,20000]

width = d3.select('#main').node().getBoundingClientRect().width - 2*margin
height = d3.select('#main').node().getBoundingClientRect().height - 2*margin

svg = d3.select 'svg'
  .attr
    width: width + 2*margin

vis = svg.append 'g'
  .attr
    width: width
    height: height
    transform: "translate(#{margin+(width-width/1.5)}, #{margin})"

thousands = d3.format(",.0f")

x = d3.scale.log()
  .range [0, width/1.5]

y = d3.scale.ordinal()

xAxis = d3.svg.axis()
  .tickValues [1,2,10,20,50,100,200,500,1000,2000,5000,10000,20000]
  .tickFormat thousands
  .scale x
  .orient 'top'

d3.json 'data.json', (error, data) ->
  data = data.results.bindings

  svg
    .attr
      height: bar_height * data.length + margin

  y
    .rangeRoundBands [0, bar_height * data.length + margin]
    .domain (data.map (d) -> d.desc.value)

  x.domain [(d3.min data, (d) -> parseInt(d.cont.value)), (d3.max data, (d) -> parseInt(d.cont.value))]

  vis.append 'g'
    .attr
      class: "x axis"
    .call xAxis

  ### ticks
  ###
  ticks = vis.selectAll '.ttick'
    .data data_ticks

  ticks.enter().append 'line'
    .attr
      class: 'ttick'

  ticks
    .attr
      'text-anchor': 'middle'
      x1: (d) -> x(d)
      y1: 0
      x2: (d) -> x(d)
      y2: bar_height * data.length

  ### Source of law
  ###
  sol = vis.selectAll '.sol'
    .data data

  sol.enter().append 'g'
    .attr
      transform: (d,i) -> "translate(0, #{y(d.desc.value)})"

  sol.append 'rect'
    .attr
      class: 'bar'
      width: (d) -> x parseInt(d.cont.value)
      height: y.rangeBand()-1

  sol.append 'text'
    .attr
      'text-anchor': 'end'
      x: -3
      y: 13
    .text (d) -> if d.desc.value.length > 40 then "#{d.desc.value.slice(0,40)}..." else d.desc.value
    .append 'title'
      .text (d) -> d.desc.value

  sol.append 'text'
    .attr
      'text-anchor': (d) -> if x(parseInt(d.cont.value)) > 15 then 'end' else 'start'
      fill: (d) -> if x(parseInt(d.cont.value)) > 15 then '#fff' else '#000'
      x: (d) -> if x(parseInt(d.cont.value)) > 15 then x(parseInt(d.cont.value))-4 else x(parseInt(d.cont.value))+4
      y: 13
    .text (d) -> thousands(parseInt(d.cont.value))

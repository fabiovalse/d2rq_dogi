margin = 
  top: 20
  right: 20
  bottom: 30
  left: 40
  
width = 960 - margin.left - margin.right
height = 500 - margin.top - margin.bottom

x = d3.scale.ordinal()
  .rangeRoundBands [0, width], .25

x2 = d3.scale.ordinal()
  
y = d3.scale.linear()
  .rangeRound [height, 0]

color = d3.scale.ordinal()
  .range ['#f2f2f2', '#67a9cf', '#ef8a62']

xAxis = d3.svg.axis()
  .scale x
  .orient 'bottom'

yAxis = d3.svg.axis()
  .scale y
  .orient 'left'
  .tickFormat d3.format('.2s')

svg = d3.select 'svg'
  .attr
    width: width + margin.left + margin.right
    height: height + margin.top + margin.bottom
  .append 'g'
    .attr
      transform: "translate(#{margin.left}, #{margin.top})"

d3.json 'data.json', (error, json_file) ->
  
  years = {}
  means = [
    {name: 'Total', value: 0},
    {name: 'Journal Articles not A-rated', value: 0},
    {name: 'Journal Articles A-rated', value: 0}
  ]
  data = []
  
  ###  SPARQL query result format is suitably converted 
  ###
  json_file.results.bindings.map (d) ->
    year = d.date.value.split('-')[0]
    
    if year of years
      if d.rate?
        years[year].a += 1
      else
        years[year]['not_a'] += 1
    else if d.rate?
      years[year] =
        a: 1
        'not_a': 0
    else
      years[year] =
        a: 0
        'not_a': 1
  
  for key, value of years
    obj = {
      year: key
      a: value.a
      'not_a': value['not_a']
      total: value.a + value['not_a']
    }
    obj.stack = [
      {name: 'Total', y0: 0, y1: value['not_a']+value.a, obj: obj},
      {name: 'Journal Articles not A-rated', y0: 0, y1: value['not_a'], obj: obj},
      {name: 'Journal Articles A-rated', y0: 0, y1: value.a, obj: obj}
    ]
  
    means[0].value += value['not_a']+value.a
    means[1].value += value['not_a']
    means[2].value += value.a
  
    data.push obj
  
  means = means.map (d) -> {name: d.name, value: d.value/data.length}
  
  x.domain data.map (d) -> d.year
  y.domain [0, d3.max(data, (d) -> d.total)]
  
  ###  Axis
  ###
  svg.append 'g'
      .attr
        class: "x axis"
        transform: "translate(0, #{height})"
      .call xAxis

  svg.append 'g'
    .attr
      class: 'y axis'
    .call yAxis
    .append 'text'
      .attr
        transform: 'rotate(-90)'
        y: 6
        dy: '.71em'
      .style
        'text-anchor': 'end'
      .text '#Articles'

  ###  Stackes bars
  ###
  years = svg.selectAll '.year'
    .data data

  years.enter().append 'g'
    .attr
      class: 'g'
      transform: (d) -> "translate(#{x(d.year)}, 0)"

  bars = years.selectAll 'rect'
    .data (d) -> d.stack
  
  bars.enter().append 'rect'
    .attr
      width: (d,i) -> if d.name is 'Total' then x.rangeBand() else x.rangeBand()/3
      x: (d,i) -> if i is 1 then x.rangeBand()/8 else if i is 2 then x.rangeBand()/2+x.rangeBand()/12 else 0
      y: (d) -> y(d.y1)
      height: (d) -> y(d.y0) - y(d.y1)
    .style
      fill: (d) -> color d.name
    .append 'title'
      .text (d) -> d.y1

  ###  Means
  ###
  svg.selectAll '.mean'
    .data means
  .enter().append 'line'
    .attr
      class: 'mean'
      x1: 0
      x2: width
      y1: (d) -> y d.value
      y2: (d) -> y d.value
      stroke: (d) -> color d.name
      
  ### Legend
  ###
  legend = svg.selectAll '.legend'
    .data color.domain().slice().reverse()
  
  legend.enter().append 'g'
    .attr
      class: 'legend'
      transform: (d,i) -> "translate(0,#{i*20})"

  legend.append 'rect'
    .attr
      x: width - 18
      width: 18
      height: 18
    .style
      fill: color

  legend.append 'text'
    .attr
      x: width - 24
      y: 9
      dy: '.35em'
    .style
      'text-anchor': 'end'
    .text (d) -> d
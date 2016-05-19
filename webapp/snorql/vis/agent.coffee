window.draw_agent_diagram = () ->
  prefixes = ""
  for key,value of D2R_namespacePrefixes
    prefixes += "PREFIX #{key}: <#{value}> "

  query = """
  SELECT ?label ?rate (COUNT(?article) AS ?cont) {

  ?article dcterms:creator <#{resource.uri}>;
  bibo:issue ?issue.

  ?issue dcterms:isPartOf ?journal.

  ?journal rdfs:label ?label .

  OPTIONAL{?journal dogi:rating ?rate.}

  } GROUP BY ?label ?rate
  """

  query = encodeURIComponent("#{prefixes} #{query}")
  url = "/sparql?query=#{query}&output=json"

  margin = 20
  width = d3.select('#main').node().getBoundingClientRect().width-margin*2
  height = 300

  svg = d3.select('#visualization').append 'svg'
  .attr
    width: width+margin*2
    height: height+margin*2
  .append 'g'
    .attr
      transform: "translate(#{margin}, #{margin})"

  color = d3.scale.ordinal()
    .domain [false, true]
    .range ['#67a9cf', '#ef8a62']

  x = d3.scale.ordinal()
  .rangeRoundBands [0, width], 0.3

  y = d3.scale.linear()
  .range [height, 0]

  x_axis = d3.svg.axis()
  .scale x
  .orient 'bottom'

  y_axis = d3.svg.axis()
  .scale y
  .orient 'left'
  .ticks 10

  d3.json url, (error, data) ->

    data = data.results.bindings.sort (a,b) ->
      a.cont.value < b.cont.value

    x.domain data.map (d) -> if d.label.value.length > 10 then "#{d.label.value.slice(0,10)}..." else d.label.value
    y.domain [0, d3.max(data, (d) -> parseInt(d.cont.value)+1)]
    color.domain data.map (d) -> d.rate?

    # axis
    svg.append 'g'
      .attr
        class: 'x axis'
        transform: "translate(0, #{height})"
      .call x_axis

    svg.append 'g'
      .attr
        class: 'y axis'
        transform: 'translate(10,0)'
      .call y_axis
      .append 'text'
        .attr
          transform: 'rotate(-90)'
          y: 6
          dy: '.71em'
          'text-anchor': 'end'
        .text 'Articles amount'

    # bars
    bars = svg.selectAll '.bar'
      .data data

    enter_bars = bars.enter().append 'rect'
      .attr
        class: 'bar'

    bars
      .attr
        x: (d) -> x(if d.label.value.length > 10 then "#{d.label.value.slice(0,10)}..." else d.label.value)
        y: (d) -> y d.cont.value
        width: x.rangeBand()
        height: (d) -> height - y(d.cont.value)
        fill: (d) -> color d.rate?
      .append 'title'
        .text (d) -> "#{d.label.value}\n#{d.cont.value} articles"

    # legend
    legend = svg.selectAll '.legend'
      .data ['A-rated Journal Articles', 'Not A-rated Journal Articles']
    
    legend.enter().append 'g'
      .attr
        class: 'legend'
        'font-family': 'sans-serif'
        'font-size': '13px'
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
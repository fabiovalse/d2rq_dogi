if resource.uri.split('/').slice(-2)[0] is 'Agent'

  prefixes = "PREFIX dc: <http://purl.org/dc/elements/1.1/> PREFIX db: <http://wafi.iit.cnr.it/dogi2020/resource/> PREFIX foaf: <http://xmlns.com/foaf/#> PREFIX schema: <http://schema.org/> PREFIX gn: <http://www.geonames.org/ontology#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX dbo: <http://dbpedia.org/ontology/> PREFIX bibo: <http://purl.org/ontology/bibo/> PREFIX d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#> PREFIX map: <http://wafi.iit.cnr.it/dogi2020/resource/#> PREFIX owl: <http://www.w3.org/2002/07/owl#> PREFIX dogi: <http://www.ittig.cnr.it/dogi/> PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> PREFIX vocab: <http://wafi.iit.cnr.it/dogi2020/resource/vocab/> PREFIX x: <http://dogi.org/>"
  #query = encodeURIComponent("#{prefixes} SELECT ?journal ?rate {?article dc:creator <#{resource.uri}>;bibo:issue ?issue.?issue dc:isPartOf ?journal.OPTIONAL{?journal x:Rating ?rate.}}")
  query = encodeURIComponent("#{prefixes} SELECT (COUNT(?rate) AS ?a) (COUNT(?journal) AS ?tot){?article dc:creator <#{resource.uri}>;bibo:issue ?issue.?issue dc:isPartOf ?journal.OPTIONAL{?journal x:Rating ?rate.}}")
  url = "http://wafi.iit.cnr.it/dogi2020/sparql?query=#{query}&output=json"

  margin = 20
  width = d3.select('#visualization').node().getBoundingClientRect().width/2-margin*2
  height = d3.select('#visualization').node().getBoundingClientRect().height/2-margin*2

  svg = d3.select('#visualization').append 'svg'
    .attr
      width: width+margin*2
      height: height+margin*2
    .append 'g'
      .attr
        transform: "translate(#{margin}, #{margin})"

  color = d3.scale.ordinal()
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
    
    a_rate = parseInt(data.results.bindings[0].a.value)
    not_a_rate = parseInt(data.results.bindings[0].tot.value) - parseInt(a_rate)

    data = [{value: a_rate, id: 'A', desc: 'articles published on journals rated with class A.'}, {value: not_a_rate, id: 'Not A', desc: 'articles published on journals rated with a class different from A.'}]

    x.domain data.map (d) -> d.id
    y.domain [0, d3.max(data, (d) -> d.value)]
    color.domain data.map (d) -> d.id

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

    bars = svg.selectAll '.bar'
      .data data

    enter_bars = bars.enter().append 'rect'
      .attr
        class: 'bar'

    bars
      .attr
        x: (d) -> x d.id
        y: (d) -> y d.value
        width: x.rangeBand()
        height: (d) -> height - y(d.value)
        fill: (d) -> color d.id
      .append 'title'
        .text (d) -> "#{d.value} #{d.desc}"

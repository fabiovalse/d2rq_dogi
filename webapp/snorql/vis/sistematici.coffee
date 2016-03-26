window.draw_journal_diagram = () ->
  width = d3.select('#main').node().getBoundingClientRect().width
  height = 500
  radius = Math.min(width, height)*2
  color_opacity = 0.7
  duration = 2000

  vis = d3.select '#visualization'
    .attr
      height: height

  svg = vis.append 'svg'
    .attr
      width: width
      height: height
      viewBox: "#{-width/2} #{-height/2} #{width} #{height}"

  # append a group for zoomable content
  zoomable_layer = svg.append('g')

  # define a zoom behavior
  zoom = d3.behavior.zoom()
    .scaleExtent([0.5,64])
    .on 'zoom', () ->
      zoomable_layer
        .attr
          transform: "translate(#{zoom.translate()})scale(#{zoom.scale()})"

      zoomable_layer.selectAll '.semantic_zoom'
        .attr
          transform: "scale(#{1/zoom.scale()})"
          
      lod zoom.scale()
      
  svg.call(zoom)

  lod = (z) ->
    zoomable_layer.selectAll '.semantic_zoom'
      .attr
        display: (d) -> if 30/z < d.dx*Math.pow(d.dy, 0.4) then 'inline' else 'none'

  partition = d3.layout.partition()
    .sort null
    .size [2 * Math.PI, radius * radius]
    .value () -> 1

  arc = d3.svg.arc()
    .startAngle (d) -> d.x
    .endAngle (d) -> d.x + d.dx
    .innerRadius (d) -> Math.pow(d.y, 0.4)
    .outerRadius (d) -> Math.pow(d.y + d.dy, 0.4)

  color = d3.scale.category10()

  get_color = (node) ->
    color node.name.split('.')[0]

  arcTween = (a) ->
    i = d3.interpolate({x: a.x0, dx: a.dx0}, a)
    return (t) ->
      b = i(t)
      a.x0 = b.x
      a.dx0 = b.dx
      return arc(b)

  d3.select '#visualization .subtitle'
    .text 'The sunburst shows the hierarchy of the Dogi classification scheme.'

  redraw = (flag) ->
    d3.json '../snorql/vis/sistematici.json', (error, root) ->
      tree_utils.canonical_sort root
      
      value = if flag then (() -> 1) else ((d) -> d.size)
        
      nodes = partition
        .value value
        .nodes root
      
      # Sectors with depth equal to 1 
      sectors_one = zoomable_layer.selectAll '.sector_one'
        .data nodes.filter (d) -> d.depth < 2

      enter_sectors_one = sectors_one.enter().append 'path'
        .attr
          class: 'sector_one'
        .each (d) ->
          d.x0 = d.x
          d.dx0 = d.dx

      enter_sectors_one.append 'title'

      sectors_one
        .attr
          d: arc
          fill: (d) -> if d.depth > 0 then get_color d else '#fff'
        ###.transition()
          .duration duration
          .attrTween 'd', arcTween###

      sectors_one.select 'title'
        .text (d) -> d.name + if d.desc? then "\n"+d.desc else ""

      sectors_one.exit().remove()
      
      # Sectors with depth greater than 1 
      sectors = zoomable_layer.selectAll '.s_link'
        .data (nodes.filter (d) -> d.depth > 1), ((d) -> "#{d.name}_#{flag}")
        
      enter_sectors = sectors.enter().append 'a'
        .attr
          class: 's_link'
          target: '_blank'
          'xlink:href': (d) -> d.url

      enter_sectors.append 'path'
        .attr
          class: 'sector'

      enter_sectors.append 'title'

      sectors.select 'path'
        .attr
          d: arc
          fill: (d) -> if d.depth > 0 then get_color d else '#fff'
      
      sectors.select 'title'
        .text (d) -> d.name + if d.desc? then "\n#{d.desc}" else ''

      sectors.exit().remove()

      # Labels
      labels = zoomable_layer.selectAll '.label'
        .data nodes, (d) -> "#{d.name}_#{flag}"
      
      enter_labels = labels.enter().append 'g'
        .attr
          class: 'label'

      enter_labels.append 'text'
        .attr
          class: 'halo semantic_zoom'

      enter_labels.append 'text'
        .attr
          class: 'halo_text semantic_zoom'

      labels
        .attr
          transform: (d) ->
            if d.name is 'DoGi' 
              'translate(0,0)'
            else
              "translate(#{(Math.pow(d.y + d.dy/2, 0.4)) * Math.cos(d.x + d.dx/2 - Math.PI/2)}, #{(Math.pow(d.y + d.dy/2, 0.4)) * Math.sin(d.x + d.dx/2 - Math.PI/2)})"
      
      labels.select '.halo'
        .attr
          dy: '0.35em'
        .text (d) -> d.name
        
      labels.select '.halo_text'
        .attr
          dy: '0.35em'
        .text (d) -> d.name

      d3.selectAll('input').on 'change', () ->
        redraw this.value is 'count'

      # Initialize the visualization with a level of detail equal to 1
      lod 1

  #redraw d3.select('input[checked]').node().value is 'count'
  redraw true
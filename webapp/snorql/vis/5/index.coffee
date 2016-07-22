width = d3.select('body').node().getBoundingClientRect().width
distance = 25
max_depth = 5.5
margin = 30
duration = 750
labels = {'DoGi': ''}

zip = () ->
  args = [].slice.call(arguments)
  shortest = if args.length == 0 then [] else args.reduce(((a,b) ->
      if a.length < b.length then a else b
  ))
  
  return shortest.map(((_,i) ->
      args.map((array) -> array[i])
  ))

tcmp = (a,b) ->
  for [ai, bi] in zip(a.children, b.children)
    ci = tcmp(ai,bi)
    if ci isnt 0
      return ci

  return b.children.length-a.children.length
    
rsort = (t) ->
  for c in t.children
    if !c.children?
      c.children = []
    rsort(c)
  t.children.sort(tcmp)

svg = d3.select 'svg'
g_link = svg.append 'g'
  .attr
    transform: "translate(#{margin}, #{margin})"
g_node = svg.append 'g'
  .attr
    transform: "translate(#{margin}, #{margin})"

d3.json 'data.json', (error, data) ->
  d3.csv 'label.csv', (error, data_labels) ->
  
    data_labels.forEach (d) ->
      id = "#{d.ns}#{if d.nd isnt 'NULL' then '_'+d.nd else ''}"

      labels[id] = d.label

    table = data.results.bindings.map (d) -> {node: d.s.value, parent: (if d.s_parent? then d.s_parent.value else 'DoGi')}
    table.push {node: 'DoGi'}

    root = (d3.stratify()
      .id (d) -> d.node
      .parentId (d) -> d.parent
      )(table)

    collapse = (d) ->
      if d.children?
        d._children = d.children
        d._children.forEach(collapse)
        d.children = null

    rsort(root)
    root.children.forEach(collapse)
    update root

diagonal = d3.svg.diagonal()
  .projection((d) -> [d.y, d.x])

tree = d3.layout.tree()
  .size [0, 0]

update = (root) ->
  height = 0
  
  nodes = tree.nodes root
  links = tree.links nodes

  ### force the layout to display nodes in fixed rows and columns
  ###
  nodes.forEach (n) ->
    if n.parent? and n.parent.children[0] isnt n
        height += distance
        
    n.x = height
    n.y = n.depth * (width / max_depth)
  
  svg
    .attr
      width: width - margin
      height: height - margin

  ### links
  ###    
  link = g_link.selectAll 'path.link'
    .data (links.filter (d) -> d.source.depth > 0), ((d) -> d.source.id+d.target.id)

  link.transition().duration(duration)
    .attr
      d: diagonal

  link_enter = link.enter().append 'path'
    .attr
      class: 'link'
      d: diagonal
    .style
      opacity: 0
  
  link_enter.transition().duration(duration)
    .style
      opacity: 0.3
  
  link.exit()
    .transition().duration(duration)
      .style
        opacity: 0
    .remove()

  ### nodes
  ###
  node = g_node.selectAll 'g.node'
    .data (nodes.filter (d) -> d.depth > 0), ((d) -> d.id)

  node.transition().duration(duration)
    .attr
      transform: (d) -> "translate(#{d.y},#{d.x})"

  node_enter = node.enter().append 'g'
    .attr
      class: 'node'
      transform: (d) -> "translate(#{d.y},#{d.x})"
    .style
      opacity: 0
    
  node_enter.transition().duration(duration)
    .style
      opacity: 1

  node_enter.append 'circle'
    .attr
      r: 5
    .on 'click', (d) -> click(d, root)
  
  node.select 'circle'
    .attr
      class: (d) -> if not(d.children? or (d._children? and d._children.length > 0)) then 'leaf'
      fill: (d) -> if d.children? or (d._children? and d._children.length > 0) then '#fff' else 'steelblue'

  node.exit()
    .transition().duration(duration)
      .style
        opacity: 0
    .remove()

  ### text
  ###
  node_enter.append 'a'
    .attr
      href: (d) -> d.id
      target: '_blank'
    .append 'text'
      .attr
      y: 0

  text = node.select 'text'
    .attr
      'text-anchor': (d) -> if d.children? or (d._children? and d._children.length > 0) then 'end' else 'start'

  tspans = text.selectAll 'tspan'
    .data ((d) -> 
      words = labels[d.id.split('/').slice(-1)].split(' ')
      if words.length > 1
        return [{text: words.slice(0,Math.floor(words.length/2)).join(' '), is_leaf: not(d.children? or (d._children? and d._children.length > 0))}, {text: words.slice(Math.floor(words.length/2)).join(' '), is_leaf: not(d.children? or (d._children? and d._children.length > 0))}]
      else
        return [{text: words[0], is_leaf: not(d.children? or (d._children? and d._children.length > 0))}]
    )

  tspans.enter().append 'tspan'
    .attr
      y: (d,i) -> 3.45+(i*10)
    .text (d) -> d.text

  tspans
    .attr
      x: (d) -> if d.is_leaf then 8 else -8

click = (d, root) ->
  if d.children?
    d._children = d.children
    d.children = null
  else
    d.children = d._children
    d._children = null
  
  update(root)
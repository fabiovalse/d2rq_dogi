left_padding = 40
class_height = 60
bar_height = 5
classes_amounts = {}

svg = d3.select 'svg'
  .attr
    height: data.length*class_height
  .append 'g'
    .attr
      transform: "translate(0, 20)"

d3.json "#{home_url}snorql/classes.json", (classes_data) ->

  for i,c of classes_data.results.bindings
    key = c.c.value.split('/').slice(-1)[0].replace('#', '')

    if key is 'Person' or key is 'Organization'
      key = 'Agent'
    else if key is 'Location'
      key = 'Country'

    classes_amounts[key] = parseInt(c.cont.value)

  bar_width = d3.scale.pow()
    .exponent(0.3)
    .range [0, d3.select('#central_section').node().getBoundingClientRect().width/2]
    .domain [0, d3.max(classes_data.results.bindings, (d) -> parseInt(d.cont.value))]

  classes = svg.selectAll '.class'
    .data data

  enter_classes = classes.enter().append 'g'
    .attr
      class: 'class'
  
  classes.append 'text'
    .attr
      class: 'title'
      x: left_padding
      y: (d,i) -> i*class_height
    .html (d) -> "<a xlink:href='#{home_url}directory/#{d.table}'>#{d.class}</a>"

  ###classes.append 'text'
    .attr
      class: 'description'
      x: left_padding
      y: (d,i) -> i*class_height+20
    .text (d) -> d.desc###

  classes.append 'rect'
    .attr
      class: 'bar'
      x: left_padding
      y: (d,i) -> i*class_height+10
      width: (d) -> bar_width classes_amounts[d.class.replace(/ /g, '')]
      height: bar_height

  classes.append 'text'
    .attr
      class: 'bar_amount'
      x: (d) -> left_padding
      y: (d,i) -> i*class_height+27
    .text (d) -> "#{classes_amounts[d.class.replace(/ /g, '')]} instances"

###container = d3.select '#classes'

classes = container.selectAll '.class'
  .data data

enter_classes = classes.enter()
    .append 'a'
      .attr
        href: (d) -> "#{home_url}directory/#{d.table}"
      .append 'div'
        .attr
          class: 'class'

enter_classes.append 'div'
  .attr
    class: 'title'
  .text (d) -> d.class

enter_classes.append 'div'
  .attr
    class: 'description'
  .text (d) -> d.desc###

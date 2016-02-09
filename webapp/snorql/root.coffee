container = d3.select '#classes'

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
  .text (d) -> d.desc
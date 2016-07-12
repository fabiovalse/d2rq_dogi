left_padding = 150
class_height = 30
bar_height = 15
classes_amounts = {}

data = [
  {"class": "Journal", "desc": "Italian academic journals related to the legal discipline.", "translation": "", "table": "tabRiviste", "main": true},
  {"class": "Issue", "desc": "Periodical publications of Italian legal journals.", "translation": "", "table": "tabRifBibl", "main": true},
  {"class": "Article", "desc": "Academic articles published within an issue of an Italian legal journals.", "translation": "", "table": "tabDocumenti", "main": true},
  {"class": "Classification", "desc": "Scheme codes, specifically developed within DoGi, for classifying academic legal articles (i.e., a pair sistematico-descrittore or a sistematico).", "translation": "", "table": "tabClassificazioni", "main": true},
  {"class": "Source Of Law", "desc": "The origin of a law. For instance, it can be international, national, regional, and so on. It represents a source as a whole or a certain partition such as an article, paragraph, letter, item or annex.", "translation": "", "table": "tabSourceOfLaw", "main": true},
  {"class": "Agent", "desc": "Agents (i.e., persons or organizations) responsible of the authorship of an academic article.", "translation": "", "table": "tabResponsabilita", "main": true},
  {"class": "Bibliography Type", "desc": "Types of bibliography used by a certain academic article (e.g., at the end of the article, footnote).", "translation": "", "table": "tabBib", "main": true},
  {"class": "Descrittore", "desc": "An additional descriptor associated to a sistematico for better qualifying its context and meaning.", "translation": "", "table": "tabDescrittori", "main": false},
  {"class": "Sistematico", "desc": "A descriptor for legal documentation identifying a certain law branch (e.g., Administrative Law, Civil Law, Criminal Law).", "translation": "", "table": "tabSistematici", "main": false},
  {"class": "Ministry", "desc": "Administrative Structure responsible for a government sector.", "translation": "", "table": "tabMinisteri", "main": false},
  {"class": "Country", "desc": "Regions identified as a distinct entity in political geography.", "translation": "", "table": "tabStati", "main": false}
]

svg = d3.select 'svg'
  .attr
    height: data.filter((d) -> d.main is true).length*class_height
  .append 'g'
    .attr
      transform: "translate(0, 20)"

d3.json "snorql/data/classes.json", (classes_data) ->

  ### Since there is not a direct mapping between rdf:type and class label
      a index for storing classes amounts is created
  ###
  for i,c of classes_data.results.bindings
    key = c.c.value.split('/').slice(-1)[0].replace('#', '')  

    if key is 'Person' or key is 'Organization'
      if 'Agent' of classes_amounts
        classes_amounts['Agent'] += parseInt(c.cont.value)
      else
        classes_amounts['Agent'] = parseInt(c.cont.value)
    else if key is 'Location'
      classes_amounts['Country'] = parseInt(c.cont.value)
    else
      classes_amounts[key] = parseInt(c.cont.value)

  x = d3.scale.pow()
    .exponent(0.3)
    .range [0, d3.select('#main').node().getBoundingClientRect().width/2]
    .domain [0, d3.max(classes_data.results.bindings, (d) -> parseInt(d.cont.value))]

  y = d3.scale.ordinal()
    .rangeRoundBands [0, 300], .5
    .domain data.map (d,i) -> i

  ### MAIN Classes
  ###
  ###classes = d3.select('#main_classes').selectAll 'tr'
    .data data.filter (d) -> d.main is true

  enter_classes = classes.enter().append 'tr'
  
  a = enter_classes.append 'a'
    .attr
      href: (d) -> "directory/#{d.table}"
    .append 'td'
      .text (d) -> d.class

  enter_classes.append 'td'
    .text (d) -> "#{d.desc}"###

  classes = d3.select('#main_classes').selectAll 'div'
    .data data.filter (d) -> d.main

  enter_classes = classes.enter().append 'div'
    .attr
      class: 'main_class'

  enter_classes.append 'a'
    .attr
      href: (d) -> "directory/#{d.table}"
    .text (d) -> d.class

  enter_classes.append 'div'
    .text (d) -> "#{d.desc}"

  ### OTHER Classes
  ###
  other_classes = d3.select('#other_classes').selectAll 'span'
    .data data.filter((d) -> d.main is false)

  other_classes.enter().append 'span'
    .html (d, i) -> if i > 0 then ", <a href='directory/#{d.table}'>#{d.class}</a>" else "<a href='directory/#{d.table}'>#{d.class}</a>"

  ### CLASSES BAR-CHART
  ###
  classes = svg.selectAll '.class'
    .data data.filter((d) -> d.main).sort (a,b) -> d3.descending(classes_amounts[a.class.replace(/ /g, '')], classes_amounts[b.class.replace(/ /g, '')])

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
  
import urllib, urllib2, json

forest = {'name': 'DoGi', 'children': []}

def add_child(node, child_url, child_name, child_desc, father_url):
  # Loops over the children of a certain node
  for c in node['children']:
    # If there's a node called FATHER_NAME append CHILD_NAME
    if c['url'] == father_url:
      c['children'].append({'name': child_name, 'desc': child_desc, 'url': child_url, 'children': []})
      return

  for c in node['children']:
    add_child(c, child_url, child_name, child_desc, father_url)

# Namespace prefixes
prefix = "PREFIX dc: <http://purl.org/dc/elements/1.1/> PREFIX db: <http://wafi.iit.cnr.it/dogi2020/resource/> PREFIX foaf: <http://xmlns.com/foaf/#> PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> PREFIX dbo: <http://dbpedia.org/ontology/> PREFIX d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#> PREFIX bibo: <http://purl.org/ontology/bibo/> PREFIX dogi: <http://www.ittig.cnr.it/dogi/> PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> PREFIX map: <http://wafi.iit.cnr.it/dogi2020/resource/#> PREFIX owl: <http://www.w3.org/2002/07/owl#> PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"

query1 = "SELECT ?s ?name ?desc WHERE {?s a dogi:Sistematico ; dc:identifier ?name ; dc:description ?desc . MINUS {?s dc:isPartOf ?s2}} ORDER BY ?name"
query2 = "SELECT ?s ?s2 ?name ?desc WHERE { ?s a dogi:Sistematico ; dc:identifier ?name ; dc:description ?desc . ?s dc:isPartOf ?s2 . } ORDER BY ASC(?s2)" 

### Adds the roots of the trees to the forest
###
f = { 'query' : prefix+query1, 'output' : "json"}
url = "http://localhost:2020/sparql?" + urllib.urlencode(f)

response = urllib2.urlopen(url)
data1 = json.load(response)

current = ""
current_index = -1

# Result loop
for r in data1['results']['bindings']:
  if current != r['name']['value'].split('.')[0]:
    current = r['name']['value'].split('.')[0]
    current_index += 1
    forest['children'].append({'name': r['name']['value'].split('.')[0], 'url': '', 'children': []})

  forest['children'][current_index]['children'].append({'name': r['name']['value'], 'desc': r['desc']['value'], 'url': r['s']['value'], 'children': []})
  
### Query2 construction and execution
###
f = { 'query' : prefix+query2, 'output' : "json"}
url = "http://localhost:2020/sparql?" + urllib.urlencode(f)

response = urllib2.urlopen(url)
data2 = json.load(response)

# Result loop
for r in data2['results']['bindings']:
  add_child(forest, r['s']['value'], r['name']['value'], r['desc']['value'], r['s2']['value'])

print json.dumps(forest)
switch table
  when "tabSistematici" then draw_journal_diagram()
  else d3.select('#visualization').remove()
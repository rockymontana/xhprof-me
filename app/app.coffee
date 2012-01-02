#require("coffee-script")
#require("coffee-script")
#eco = require 'eco'

XHProf = require("xhprof")

App =
  init: ->
    # Bootstrap the app

    #$.get 'views/xhprof_run.eco', (tmpl) =>
    #tmpl_data = {headers: headers, rows: rows}
    ##keyboardInfoTable = Mustache.to_html(tmpl, tmpl_data);
    #eco.render tmpl, tmp_data
    #require("views/xhprof_runs")


    element = document.getElementById("drop-area")
    element.addEventListener("dragover", (event) ->
      event.stopPropagation()
      event.preventDefault()
    , true)

    element.addEventListener("drop", (e) =>
      e.stopPropagation()
      e.preventDefault()

      files = e.dataTransfer.files
      console.dir this
      @handleFiles(files)
      for f in files
        console.log(f)
    , false)

  noopHandler: (e) ->
    e.stopPropagation()
    e.preventDefault()

  handleFiles: (files) ->
    file = files[0]

    reader = new FileReader()

    # init the reader event handlers
    reader.onloadend = (evt) => @handleReaderLoadEnd(evt)

    # begin the read operation
    reader.readAsText(file)

  handleReaderProgress: (evt) ->
    if (evt.lengthComputable)
      loaded = (evt.loaded / evt.total)

      $("#progressbar").progressbar({ value: loaded * 100 })

  handleReaderLoadEnd: (evt) ->
    # Get the raw serialized array from the file dropped.
    file_contents = evt.target.result

    # Unserialize the data and flatten the dag into per symbol stats.
    xhprof_obj = unserialize(file_contents)
    xhprof = new XHProf(xhprof_obj)
    xhprof_data = xhprof.computeFlatInfo()

    totals = {}
    for metric, total of xhprof.getTotals()
      totals[metric] = @numberFormat(total)

    console.log totals

    # Render eco template for runs summary.
    summary_template = require("views/xhprof/summary")
    summary = summary_template(totals)

    # Render eco template for runs table.
    runs_template = require("views/xhprof/runs")
    runs = runs_template({symbols: xhprof_data})

    #document.body.appendChild(element)
    $("#drop-area").replaceWith(summary + runs)
    $("#xhprof-runs").tablesorter()

  numberFormat: (number) ->
    # Use number_format from php.js
    number_format(number)


module.exports = App
<!DOCTYPE html>
<html>
<head>
    <title>${hda.name | h} | ${visualization_name}</title>
    <%
        root = h.url_for( '/' )
        ## Ensure BAI index is symlinked
        bai_target = hda.file_name+'.bai'

        import os

        if not os.path.isfile(bai_target):
            os.symlink(hda.metadata.bam_index.file_name, bai_target)
    %>
    <!-- include iobio libs -->
    ${h.stylesheet_link( root + 'static/plugins/visualizations/bamviewer-iobio/static/iobio.viz.min.css' )}
    <!--${h.javascript_link( root + 'static/plugins/visualizations/bamviewer-iobio/static/js-local-bam.min.js' )} -->
    ${h.javascript_link( root + 'static/plugins/visualizations/bamviewer-iobio/static/iobio.min.js' )}
    ${h.javascript_link( root + 'static/plugins/visualizations/bamviewer-iobio/static/iobio.viz.min.js' )}
    ${h.javascript_link( root + 'static/plugins/visualizations/bamviewer-iobio/static/iobio.viz.min.js' )}
    <!-- include 3rd party libs -->
    <!--
    <link rel="stylesheet" type="text/css" href="https://raw.githubusercontent.com/iobio/example-bamViewer/master/assets/css/iobio.viz.min.css">
    <script src="https://raw.githubusercontent.com/iobio/example-bamViewer/master/assets/js/js-local-bam.min.js" charset="utf-8"></script>
    <script src="https://raw.githubusercontent.com/iobio/example-bamViewer/master/assets/js/iobio.min.js" charset="utf-8"></script>
    <script src="https://raw.githubusercontent.com/iobio/example-bamViewer/master/assets/js/iobio.viz.min.js" charset="utf-8"></script>
    -->

    <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.5/d3.min.js" charset="utf-8"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.0/jquery.min.js"></script>
    <script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
    <script type="text/javascript" src='http://underscorejs.org/underscore-min.js'></script>
    <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">

    <style type="text/css">
        .container { margin-top: 100px; }
        #spinner { display: none; margin-top: 60px; }
    </style>
</head>

<body>

    <div class='container text-center'>
        <!-- Title -->
        <h1>BAM Viewer</h1>

        <!-- inputs -->
        <div  id="input">
            <!-- region input -->
            <div>Region: <input id='region' type='text' value="[chr17:958783-9677387]" ></input></div>

            <!-- url input -->
            <button class='btn btn-info' type="button" data-toggle="modal" data-target="#urlModal" onclick='goBAM()'>Open Url</button>

            <!-- file input -->
            <label class="btn btn-info" for="my-file-selector">
                <input id="my-file-selector" onchange="goBAM(this)" type="file" style="display:none;" multiple>
                Open File
            </label>
        </div>

        <!-- spinner -->
        <img id='spinner' src="https://raw.githubusercontent.com/iobio/example-bamViewer/master/assets/img/spinner.gif"></img>
        <!-- Visualization -->
        <div id='viz' style="width: 100%;"></div>

    </div>

    <script type="text/javascript">
        var margin = {top: 30, left: 30, right: 30, bottom: 30},
            width = 800,
            height = 500;
        function goBAM(evt) {

            var raw_url = '${h.url_for( controller="/datasets", action="index" )}';
            var hda_id = '${trans.security.encode_id( hda.id )}';
            var url = raw_url + '/' + hda_id + '/display?to_ext=json';
            // url="http://localhost:8080/api/datasets/f597429621d6eb2b?data_type=raw_data&provider=column&limit=2&offset=1";
            url="http://localhost:8080/api/datasets/f597429621d6eb2b?data_type=raw_data&provider=samtools&options_string=%22%22";
                        // var region = $('#region').val();
            var region = $('#region').val();
            var chr = region.split(':')[0];
            var start = +region.split(':')[1].split('-')[0];
            var end = +region.split(':')[1].split('-')[1];


            var xhr = jQuery.getJSON( "/api/datasets/f597429621d6eb2b", {
                data_type : 'raw_data',
                provider  : 'samtools',
                regions  : region
                // limit     : 2,
                // offset    : 1
            });
            $('#spinner').css('display', 'inline');
            xhr.done( function( response ){
                $('#spinner').css('display', 'none');
                console.log( response.data );
                // [["2", "20", "22", "220"], ["3", "30", "33", "330"]]
                // ...do something with data
            });
        }
        // Draw Alignment Visualization
        function draw(alns) {
            // Hide spinner
            $('#spinner').css('display', 'none');
            // Create pileup layout to calculate position
            var pileup = iobio.viz.layout.pileup().sort(null).size(width);
                // Create alignment chart with attributes
            console.log(width)
            console.log(height)
            var chart = iobio.viz.alignment()
                .width(width)
                .height(height)
                .margin(margin)
                .yAxis(null)
                .xValue(function(d) { return d.x; })
                .yValue(function(d) { return d.y; })
                .wValue(function(d) { return d.w; })
                // .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
                .id(function(d) { return 'read-' + d.data.id.replace('.', '_'); })
                .tooltip(function(d) { return "id:  " + d.data.id + "<br/>" + "pos: " + d.data.start + ' - ' + d.data.end + "<br/>"});

            // Create selection with viz div and the alignment data
            var selection = d3.select('#viz').datum( pileup(alns))

            selection.attr("transform", "translate(" + margin.left + "," + margin.top + ")");;
                     // .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
            // Draw chart
            console.log(selection)
            chart(selection);
            alert("Hi");
            return(selection);
        }
        // Test visualization
        // Temporary data for testing
        alns = [{start:1, end:3, id:'1'}, {start:2, end:4, id:'2'}, {start:3, end:5, id:'3'},{start:4, end:6, id:'4'}];

        xx = draw(alns);

    </script>

</body>
</html>

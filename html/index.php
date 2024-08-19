<!doctype html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="style.css" media="screen"/>
    <meta charset="utf-8">
    <title>Observatory Weather Status</title>
</head>
<body>
    <h1>Weather status and forecast</h1>
	<a class="weatherwidget-io" href="https://forecast7.com/fr/48d067d42/andolsheim/" data-label_1="ANDOLSHEIM" data-label_2="WEATHER" data-theme="dark" >ANDOLSHEIM WEATHER</a>
	<script>
	!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='https://weatherwidget.io/js/widget.min.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','weatherwidget-io-js');
	</script>
    <p style="clear: both;">

    <h1>Sky camera and satelite view</h1>
    <div class="row">
		 <div class="column">
		 	<a href="http://allsky/allsky/index.php">
				<img src="http://allsky/current/tmp/image.jpg" alt="Picture not found" style="width:100%">
			</a>
		 </div>
		 <div class="column">
    		<iframe src="https://www.meteoblue.com/en/weather/maps/widget/andolsheim_france_3037706?windAnimation=0&gust=0&satellite=0&satellite=1&geoloc=fixed&tempunit=C&windunit=km%252Fh&lengthunit=metric&zoom=5&autowidth=auto"  frameborder="0" scrolling="NO" allowtransparency="true" sandbox="allow-same-origin allow-scripts allow-popups allow-popups-to-escape-sandbox" style="width: 100%; height: 450px"></iframe>
		    <div>
    		<!-- DO NOT REMOVE THIS LINK -->
    		<a href="https://www.meteoblue.com/en/weather/maps/andolsheim_france_3037706?utm_source=weather_widget&utm_medium=linkus&utm_content=map&utm_campaign=Weather%2BWidget" target="_blank">meteoblue</a>
	    	</div>
		 </div>
	</div>



    <h1>Weather conditions and sky data graph</h1>
<!--	
    <p>Weather Status</p>	
-->
	<?php include('status.php') ?>
    <h2>Sky conditions last 3 hours</h2>
    <div class="row">
		 <div class="column">
			<img src="images/aagcloud-cloudcover-lasthour.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-humidity-lasthour.png" style="width:100%">
		 </div>
	</div>
	<div class="row">
		 <div class="column">
			<img src="images/aagcloud-light-lasthour.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/temp-and-dewpoint-lasthour.png" style="width:100%">
		 </div>
	</div>
    <h2>Sky conditions last 24 hours</h2>
    <div class="row">
		 <div class="column">
			<img src="images/aagcloud-cloudcover-lastday.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-humidity-lastday.png" style="width:100%">
		 </div>
	</div>
	<div class="row">
		 <div class="column">
			<img src="images/aagcloud-light-lastday.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/temp-and-dewpoint-lastday.png" style="width:100%">
		 </div>
	</div>	
    <h2>All sensors data collected last 3 hours</h2>
    <div class="row">
		 <div class="column">
			<img src="images/aagcloud-sky-lasthour.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-rain-lasthour.png" style="width:100%">
		 </div>
	</div>
	<div class="row">
		 <div class="column">
			<img src="images/aagcloud-temp-lasthour.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-all-lasthour.png" style="width:100%">
		 </div>
	</div>
    <h2>All data collected last 24 hours</h2>
    <div class="row">
		 <div class="column">
			<img src="images/aagcloud-sky-lastday.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-rain-lastday.png" style="width:100%">
		 </div>
	</div>
	<div class="row">
		 <div class="column">
			<img src="images/aagcloud-temp-lastday.png" style="width:100%">
		 </div>
		 <div class="column">
			<img src="images/aagcloud-all-lastday.png" style="width:100%">
		 </div>
	</div>
</body>
<style>
.aligncenter {
    text-align: center;
}

* {
  box-sizing: border-box;
}

/* Two image containers (use 25% for four, and 50% for two, etc) */
.column {
  float: left;
  width: 50%;
  padding: 5px;
}

/* Clear floats after image containers */
.row::after {
  content: "";
  clear: both;
  display: table;
} 
</style>
</html>

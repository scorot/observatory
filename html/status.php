<?php
$txt_file    = file_get_contents('weather.txt');
$rows        = explode("\n", $txt_file);
array_shift($rows);

//date format
$format='H:i:s';

foreach($rows as $row => $data)
{
    //get row data
    $row_data = explode('=', $data);
	//echo $row_data;
	$name = $row_data[0];
	$value = $row_data[1];
	

	if($name == 'precip')
	{
		$precip=$value;
	}
	if($name == 'temperature')
	{
		$temperature=$value;
	}
	if($name ==  'wind')
	{
		$wind=$value;
	}
	if($name == 'pressure')
	{
		$pressure=$value;
	}
	if($name == 'dewpoint')
	{
		$dewpoint=$value;
	}
	if($name == 'clouds')
	{
		$clouds=$value;
	}
	if($name == 'humidity')
	{
		$humidity=$value;
	}
	if($name == 'date')
	{
		$timestamp=$value;
	}	
	if($name == 'forecast')
	{
		$forecast=$value;
	}
}


$green = '#40FF00';
$yellow = '#FFFF00';
$red = '#FE2E2E';

$status_msg = "<p style='text-align:center'>";

if($wind <= 5.) {
	$wind_status = "<font color=$green>" . "OK"  . '</font> ';
} elseif($wind <= 10.) {
	$wind_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$wind_status = "<font color=$yellow>" . "Warning"  . '</font> ';
}
$status_msg = $status_msg . 'Wind speed is ' . $wind . 'm/s  ' . $wind_status . '&emsp;' ;

if($temperature <= -5.) {
	$temperature_status = "<font color=$red>" . "Danger"  . '</font> ';
} elseif($temperature <= 0.) {
	$temperature_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} elseif($temperature > 30.) {
	$temperature_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$temperature_status = "<font color=$green>" . "OK"  . '</font> ';
}
$status_msg =  $status_msg  . "temperature is $temperature" . "°C " . $temperature_status . '&emsp;';


$dewpoint_diff = $temperature - $dewpoint;
if($dewpoint_diff <= 1.) {
	$dewpoint_status = "<font color=$red>" . "Danger"  . '</font> ';
} elseif($dewpoint_diff <= 3.) {
	$dewpoint_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$dewpoint_status = "<font color=$green>" . "OK"  . '</font> ';
}
$status_msg =  $status_msg  . "Dewpoint is $dewpoint" . "°C " . $dewpoint_status . '&emsp;';
#$status_msg =  $status_msg  . "Dewpoint is $dewpoint" . "°C " . $dewpoint_status . '<br>';


if($humidity <= 80.) {
	$humidity_status = "<font color=$green>" . "OK"  . '</font> ';
} elseif($humidity <= 90.) {
	$humidity_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$humidity_status = "<font color=$red>" . "Danger"  . '</font> ';
}
$status_msg =  $status_msg  . "Relative humidity is $humidity%  " . $humidity_status . '&emsp;';
#$status_msg =  $status_msg  . "Relative humidity is $humidity%  " . $humidity_status . '<br>';


if($clouds <= -5.) {
	$clouds_status = "<font color=$green>" . "OK"  . '</font> ';
} elseif($clouds <= -6.) {
	$clouds_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$clouds_status = "<font color=$red>" . "Danger"  . '</font> ';
}
$status_msg =  $status_msg  . "Cloud cover is " . $clouds_status . '&emsp;';
#$status_msg =  $status_msg  . "Cloud cover is " . $clouds_status . ' </p>';


if($forecast > 805) {
	$forecast_status = "<font color=$red>" . "Danger"  . '</font> ';
} elseif($forecast > 800 ) {
	$forecast_status = "<font color=$yellow>" . "Warning"  . '</font> ';
} else {
	$forecast_status = "<font color=$green>" . "OK"  . '</font> ';
}
$status_msg =  $status_msg  . "Weather forecast is " . $forecast_status . ' </p>';

echo '<h2>Weather Status at ' . date($format, $timestamp) . ' </h2>';
echo $status_msg;

//echo "Pressure is $pressure hPa <br />";
echo '<br />';
?>
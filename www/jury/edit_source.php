<?php

require('init.php');
require(LIBDIR . '/lib.sourcecode.php');

$id = getRequestID();

editSourceCode($id, $teamid);
	
?>
<?php

$serverName = "db";  

echo "Conectando ao banco de dados...<br>";  
/* Connect using Windows Authentication. */  
try  
{  

	$conn = new PDO( "sqlsrv:server=$serverName ; Database=TestDB", "sa", "usuario@senha");  
	$conn->setAttribute( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );  
	echo "Conectado com sucesso ... ";
}  
catch(Exception $e)  
{   
	die('Erro causado por: '. print_r( $e->getMessage() ) );   
}  

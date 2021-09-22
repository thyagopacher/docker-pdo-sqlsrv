<?php
    $itens_oportunidade = array();

    $itens_oportunidade[] = array('fabricante_codigo' => 333, 'tipo_produto' => 1);
    $itens_oportunidade[] = array('fabricante_codigo' => 2, 'tipo_produto' => 2);


    $key1 = array_search(333, array_column($itens_oportunidade, 'fabricante_codigo'));
    $key2 = array_search(11, array_column($itens_oportunidade, 'tipo_produto'));

    echo "Achou o codigo: $key1 - KEY: $key2";

    var_dump($key2);
?>
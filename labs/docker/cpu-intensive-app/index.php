<?php
  ini_set('max_execution_time', 300);
  $x = 0.0001;
  for ($i = 0; $i <= 10000000000; $i++) {
    $x += sqrt($x);
  }
  echo "\$x = $x\n";
  echo "OK!";
?>
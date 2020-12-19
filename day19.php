<?php

function test($inp, $no, $rules) {
  if (!$inp) return [];
  $rule = $rules[$no];

  if (is_string($rule)) {
    if (substr($inp, 0, strlen($rule)) === $rule)
        return [[[$rule], substr($inp, strlen($rule))]];
    return [];
  }

  $res = [];
  foreach ($rule as $or) {
    $tests = [[[], $inp, $or]];
    while ($tests) {
      list($matches, $left, $terms) = array_shift($tests);
      $no = array_shift($terms);
      $sub = test($left, $no, $rules);
      foreach ($sub as $r) {
        list($m, $l) = $r;
        if ($terms) {
          array_push($tests, [array_merge($matches, [$m,$no]), $l, $terms]);
        } else {
          array_push($res, [array_merge($matches, [$m,$no]), $l]);
        }
      }
    }
  }
  return $res;
}

function parse() {
  $rules = $input = [];
  while($f = fgets(STDIN)){
    $f = trim($f);
    if ($f == "") continue;
    if (strpos($f, ':')) {
      list($no, $rule) = explode(': ', $f);
      if ($rule[0] === '"') {
        $rules[$no] = trim($rule, '"');
      } else {
        $rules[$no] = [];
        foreach (explode(' | ', $rule) as $pair) {
          $rules[$no][] = explode(' ', $pair);
        }
      }
    } else {
      $input[] = $f;
    }
  }
  return [$rules, $input];
}

function check($rules, $input) {
  $valid = 0;
  foreach ($input as $f) {
    $results = test($f, 0, $rules);
    foreach ($results as $res) {
      list ($matches, $left) = $res;
      if ($matches && $left === '') {
        $valid++;
      }
    }
  }
  return $valid;
}

list($rules, $input) = parse();
echo check($rules, $input).PHP_EOL;

$rules[8] = [[42], [42, 8]];
$rules[11] = [[42, 31], [42,11,31]];
echo check($rules, $input).PHP_EOL;

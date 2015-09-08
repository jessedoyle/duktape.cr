var sum = 0;

function add(x, y){
  return x + y;
}

for (var i = 0; i < 10; i++){
  sum += add(i, i);
}

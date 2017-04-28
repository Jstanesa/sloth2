% program to generate list of the first N fibs

N := input;
a := 0;
b := 1;
f := 1;

print f;    % print out the first one
while N > 1 do
begin
  % update vars
  f := a + b;
  a := b;
  b := f;
  N := N - 1;
  print f;  % print the next fib
end

% all done!
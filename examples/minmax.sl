% find the smallest and largest of a set of numbers

% get the amount of numbers to input
N := input;
min := 99999999;
max := 0 - 99999999;

while N > 0 do begin
  % get the next number
  x := input;

  % check if it's the min
  if x < min then
    min := x;   % set it

  % check if it's the max
  if x > max then
    max := x;   % set it

  % keep counting
  N := N - 1;
end

% print the min and max
print min;
print max;
x:=input;
myArray[x+3.0];
array2[3];
array2[1]:=2;
while x>=0 do begin
    myArray[x+array2[1]] := 0;
    myArray[x+array2[1]] :=myArray[x+array2[1]]+x+array2[1];
    print myArray[x+array2[1]];
    x:=x-1;
    end

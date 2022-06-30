program simple_while;
const a=3; b=5; c=8; bool = false;
begin
    while (a>=0) and (bool = false) do
    begin
        write(a);
        a:= a-1;
        if a=1 then
            bool := true;
    end;
end.
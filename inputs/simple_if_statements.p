program simple_if_statements;
const y=2; z=3; 
begin
    if y=2 then 
        begin
            if z=3 then
                begin 
                    y:=y-1;
                    z:=z+1;
                end;
        end;
    write(y);
    write(z);
end.
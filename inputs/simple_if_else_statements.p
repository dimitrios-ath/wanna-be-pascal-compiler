program simple_if_else_statements;
const y=6; z=5; 
begin
    if y=2 then y:=0
    else
        begin
            if y=3 then y:=5
            else
                begin 
                    y:=4*3-1+2;
                    z:=9;
                end;
        end;
    write(y);
    write(z);
end.
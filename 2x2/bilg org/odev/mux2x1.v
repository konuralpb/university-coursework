module mux_2x1(out, a, b, select);
    input a, b;
    input select;
    wire and_1, and_2, select_not;
    output out;
    not (select_not, select);
    and (and_1, a, select);
    and (and_2, b, select_not);
    or (out, and_1, and_2);
endmodule
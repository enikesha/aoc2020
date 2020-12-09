-module(day9).
-export([part1/2, part2/2]).

part1(File, Preambule) ->
    {ok, Device} = file:open(File, [read, read_ahead]),
    try solve1(Device, Preambule) after file:close(Device) end.

part2(File, Sum) ->
    {ok, Device} = file:open(File, [read, read_ahead]),
    try solve2(Device, Sum) after file:close(Device) end.

process(Device, Parser, Processor) ->
    case file:read_line(Device) of
        {ok, Line} -> case Processor(Parser(Line)) of
                          {stop, Result} -> Result;
                          Continue -> process(Device, Parser, Continue)
                      end;
        _ -> eof
    end.

parse_int(Line) -> {Int, "\n"} = string:to_integer(Line), Int.

has_sum(_, [_|[]]) -> no;
has_sum(Value, [Head | Rest]) ->
    case Head + lists:last(Rest) of
        Sum when Sum > Value -> has_sum(Value, [Head | lists:droplast(Rest)]);
        Sum when Sum < Value -> has_sum(Value, Rest);
        _ -> yes
    end.

solve1(Device, Preambule) -> process(Device, fun parse_int/1, fun(Int) -> solve1(Int, Preambule, [], []) end).
solve1(Value, Add, Sorted, Fifo) when Add > 0 -> fun(I) -> solve1(I, Add - 1, lists:merge([Value], Sorted), [Value|Fifo]) end;
solve1(Value, 0, Sorted, Fifo) ->
    case has_sum(Value, Sorted) of
        yes -> fun(I) -> solve1(I, 0, lists:merge([Value], lists:delete(lists:last(Fifo), Sorted)), [Value | lists:droplast(Fifo)]) end;
        _ -> {stop, Value}
    end.

solve2(Device, Sum) -> process(Device, fun parse_int/1, fun(Int) -> solve2(Int, Sum, [], 0) end).
solve2(Value, Sum, Sublist, SubSum) ->
    case SubSum + Value of
        S when S < Sum -> fun(I) -> solve2(I, Sum, [Value|Sublist], S) end;
        S when S > Sum -> solve2(Value, Sum, lists:droplast(Sublist), SubSum - lists:last(Sublist));
        _ -> {stop, lists:min([Value|Sublist]) + lists:max([Value|Sublist])}
    end.

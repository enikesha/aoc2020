-module(day9).
-export([part1/2, part2/2]).

part1(File, Preambule) ->
    {ok, Device} = file:open(File, [read, read_ahead]),
    try solve1(Device, Preambule) after file:close(Device) end.

part2(File, Sum) ->
    {ok, Device} = file:open(File, [read, read_ahead]),
    try solve2(Device, Sum) after file:close(Device) end.

solve1(Device, Preambule) ->
    process(Device, fun parse_int/1, fun(Int) -> solve1(Int, Preambule, []) end).

solve2(Device, Sum) ->
    process(Device, fun parse_int/1, fun(Int) -> solve2(Int, Sum, []) end).

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

solve1(Value, Add, Previous) when Add > 0 -> fun(I) -> solve1(I, Add - 1, [Value|Previous]) end;
solve1(Value, 0, Previous) ->
    case has_sum(Value, lists:sort(Previous)) of
        yes -> fun(I) -> solve1(I, 0, [Value | lists:droplast(Previous)]) end;
        _ -> {stop, Value}
    end.

find_sum(_, [], _) -> no;
find_sum(Sum, [Head|Rest], Sublist) ->
    case lists:sum(Sublist) of
        S when S > Sum -> find_sum(Sum, [Head|Rest], lists:droplast(Sublist));
        S when S < Sum -> find_sum(Sum, Rest, [Head|Sublist]);
        _ -> Sublist
    end.

solve2(Value, Sum, Previous) ->
    List = [Value|Previous],
    case find_sum(Sum, List, []) of
        no -> fun(I) -> solve2(I, Sum, List) end;
        Sublist -> {stop, lists:min(Sublist) + lists:max(Sublist)}
    end.

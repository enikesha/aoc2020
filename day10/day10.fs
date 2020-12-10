open System

let part1 jolts =
    let inc idx (A:int[]) =
        A.[idx] <- A.[idx] + 1
        A

    jolts
    |> List.fold (fun (prev, A) i -> (i, inc (i-prev-1) A)) (0, [|0;0;0|])
    |> fun (m, L) -> L.[0] * (L.[2]+1)

let part2 jolts =
    let subs = [|0L; 1L; 1L; 2L; 4L; 7L|]

    jolts
    |> List.fold (fun (p,i,L) x -> if (x > p+1) then (x, x, (p-i+1)::L) else (x, i, L)) (0, 0,[])
    |> fun (x,i,L)-> (x-i+1)::L
    |> List.map (fun l -> subs.[l])
    |> List.reduce (fun x y -> x*y)

let readInts path = IO.File.ReadLines path |> Seq.map int |> List.ofSeq

[<EntryPoint>]
let main argv =
    let input = List.sort <| readInts "input.txt"
    printfn "%A" <| part1 input
    printfn "%A" <| part2 input
    0 // return an integer exit code

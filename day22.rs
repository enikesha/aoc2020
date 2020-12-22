use std::io::{self, Read};
use std::collections::HashMap;

type Deck = Vec<i64>;

fn draw(players: &mut[Deck]) -> Vec<(i64,usize)> {
    players.iter_mut().map(|d| d.drain(..1).next()).zip(0..)
        .filter_map(|(c,i)| c.map(|c| (c, i)))
        .collect()
}

fn card(deal: &[(i64,usize)], player: usize) -> i64 {
    deal.iter().find_map(|(c,i)| if *i == player {Some(*c)} else {None}).unwrap()
}

fn collect(players: &mut[Deck], deal: &[(i64,usize)], winner: usize) {
    players[winner].push(card(deal, winner));
    players[winner].extend(deal.iter().take_while(|(_,i)| *i != winner).map(|(c,_)|c));
    players[winner].extend(deal.iter().skip_while(|(_,i)| *i != winner).skip(1).map(|(c,_)|c));
}

fn has_won(players: &[Deck], winner: usize) -> bool {
    players.iter().zip(0..).all(|(d,i)| i == winner || d.is_empty())
}

fn game(players: &mut[Deck]) -> usize {
    loop {
        let deal = draw(players);
        let (_, winner) = *deal.iter().max_by_key(|(c,_)|c).unwrap();
        collect(players, &deal, winner);
        if has_won(players, winner) {
            break winner;
        }
    }
}

fn score(result: &[i64]) -> i64 {
    result.iter().zip((0..=result.len() as i64).rev())
        .fold(0i64, |a, (v, i)| a + v * i)
}

fn copy(decks: &[Deck]) -> Vec<Deck> {
    decks.iter().map(|d| d.to_vec()).collect()
}

fn rec_game(players: &mut[Deck], level: u32) -> usize {
    let mut games : HashMap<Vec<Deck>, u32> = HashMap::new();

    let mut i = 0;
    loop {
        i += 1;
        if games.contains_key(players) {
            //println!("0 win by recurs: {:?}, {}", players, games[players]);
            break 0
        }
        games.insert(copy(players), i);

        let deal = draw(players);
        let can_recurse = players.iter().zip(0..).all(|(d,i)| d.len() >= (card(&deal, i) as usize));

        let winner = if can_recurse {
            let mut decks = players.iter().zip(0..)
                .map(|(d,i)| d.iter().take(card(&deal, i) as usize).cloned().collect())
                .collect::<Vec<Deck>>();
            //println!("Recursing with {:?}", decks);
            rec_game(&mut decks, level + 1)
        } else {
            deal.iter().max_by_key(|(c,_)|c).unwrap().1
        };
        collect(players, &deal, winner);
        //println!("Game {}:{}: deals {:?}, won {}, {:?}", level, i, deal, winner, players);

        if has_won(players, winner) {
            break winner;
        }
    }
}

fn main() -> io::Result<()> {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer)?;

    let decks = buffer.trim().split("\n\n")
        .map(|p| p.split("\n").skip(1).map(|c| c.parse().unwrap()).collect::<Deck>())
        .collect::<Vec<Deck>>();
    //println!("{:?}", decks);

    let mut players1 = copy(&decks);
    let winner = game(&mut players1);
    println!("{}", score(&players1[winner]));

    let mut players2 = copy(&decks);
    let winner2 = rec_game(&mut players2, 1);
    println!("{}", score(&players2[winner2]));

    Ok(())
}

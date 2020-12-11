package main

import (
	"os"
	"fmt"
	"bufio"
	"log"
)

type Seating struct {
	seats []string
}

func neigh(s Seating, x, y int) int {
	neigh := 0

	for dy := -1; dy < 2; dy++ {
		if y+dy < 0 || y+dy >= len(s.seats) {
			continue
		}
		row := s.seats[y+dy]
		for dx := -1; dx < 2; dx++ {
			if x+dx < 0 || x+dx >= len(row) || (dx == 0 && dy == 0) {
				continue
			}
			if row[x+dx] == '#' {
				neigh++
			}
		}
	}

	return neigh
}

func (s *Seating) step(max int, neigh func(Seating, int, int) int) bool {
	changed := false

	var next []string
	for y, row := range s.seats {
		next_row := []rune{}
		for x, seat := range row {
			switch n := neigh(*s, x,y); {
			case seat == 'L' && n==0:
				next_row = append(next_row, '#')
				changed = true
			case seat == '#' && n >= max:
				next_row = append(next_row, 'L')
				changed = true
			default:
				next_row = append(next_row, seat)
			}
		}
		next = append(next, string(next_row))
	}

	s.seats = next

	return changed
}

func (s Seating) findOccupied(x, y, dx, dy int) bool {
	if dx == 0 && dy == 0 {
		return false
	}

	x += dx
	y += dy
	for y >= 0 && y < len(s.seats) && x >= 0 && x < len(s.seats[y]) {
		if s.seats[y][x] != '.' {
			return s.seats[y][x] == '#'
		}
		x += dx
		y += dy
	}

	return false
}

func neigh2(s Seating, x, y int) int {
	neigh := 0

	for dy := -1; dy < 2; dy++ {
		for dx := -1; dx < 2; dx++ {
			if s.findOccupied(x,y,dx,dy) {
				neigh++
			}
		}
	}

	return neigh
}


func (s Seating) occupied() int {
	count := 0
	for _, row := range s.seats {
		for _, seat := range row {
			if seat == '#' {
				count++
			}
		}
	}
	return count
}

func read(file *os.File) Seating {
	scanner := bufio.NewScanner(file)

	var seats []string
	for scanner.Scan() {
		seats = append(seats, scanner.Text())
	}

	return Seating{seats}
}

func main() {
	file, err := os.Open("day11_input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err = file.Close(); err != nil {
			log.Fatal(err)
		}
	}()

	s := read(file)
	seats := s.seats

	steps := 0
	for s.step(4, neigh) { steps++ }
	fmt.Printf("Part1: After %v steps %v occupied\n", steps, s.occupied())

	s.seats = seats
	steps = 0
	for s.step(5, neigh2) { steps++ }
	fmt.Printf("Part2: After %v steps %v occupied\n", steps, s.occupied())
}

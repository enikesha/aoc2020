// gcc day6.cpp -lstdc++ -o day6

#include <iostream>
#include <iterator>
#include <map>
#include <set>
#include <string>

using namespace std;

int main() {
  int any_answers = 0, all_answers = 0, persons = 0;
  map<char,int> answers;

  for (string line; getline(cin, line);) {
    if (line != "") {
      for (auto c : line) answers[c]++;
      persons++;
    } else {
      any_answers += answers.size();
      for (auto p : answers) if (p.second == persons) all_answers++;
      answers.clear();
      persons = 0;
    }
  }
  any_answers += answers.size();
  for (auto p : answers) if (p.second == persons) all_answers++;

  cout << "Part 1: " << any_answers << " Part 2: " << all_answers << endl;

  return 0;
}

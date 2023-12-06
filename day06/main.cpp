#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

// Hold a button for x ms, gives the boat x mm/ms speed for the rest of the race

using u16 = unsigned short;

std::string fileName = "day06/input.txt";
static auto parseLine(std::string const &, std::vector<u16> &) -> void;
static auto waysToBeat(u16 time, u16 distance) -> u16;

auto main(void) -> int {
    std::string fileContents;
    {
        std::ifstream fs(fileName);
        while (fs.good()) {
            char nextChar = (char)fs.get();
            if (nextChar == EOF)
                break;
            fileContents += nextChar;
        }
    }

    std::vector<u16> time;
    std::vector<u16> distance;

    parseLine(fileContents, time);
    parseLine(fileContents.substr(fileContents.find_first_of('\n', 0) + 1), distance);

    unsigned int ways = 1;
    for (int i = 0; i < time.size(); ++i) {
        ways *= waysToBeat(time[i], distance[i]);
    }

    std::cout << ways << std::endl;
}

static auto waysToBeat(u16 time, u16 distance) -> u16 {
    u16 start, end;
    auto lambda = [&](u16 conv, u16 &modifiee) -> bool {
        u16 dist = conv * (time - conv);
        if (dist > distance) {
            modifiee = conv;
            return true;
        }
        return false;
        };

    for (u16 converge = 0; converge <= time; ++converge) {
        if (lambda(converge, start)) break;
    }
    for (u16 converge = time; converge >= 0; --converge) {
        if (lambda(converge, end)) break;
    }

    return end + 1 - start;
}

static auto parseLine(std::string const &line, std::vector<u16> &vec) -> void {
    std::stringstream ss;
    ss << line.substr(line.find_first_of(':', 0) + 1);

    u16 number;
    while (ss >> number)
        vec.push_back(number);
}
